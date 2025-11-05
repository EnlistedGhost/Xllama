// Package gptoss implements OpenAI's GPT-OSS (OpenAI MOE) language model family.
//
// GPT-OSS Architecture:
// - OpenAI's open-weight models released under Apache 2.0 license (2024-2025)
// - Two variants: gpt-oss-120b (117B params, 5.1B active) and gpt-oss-20b (21B params, 3.6B active)
// - Mixture-of-Experts (MoE) with sparse activation for efficient inference
// - Alternating attention: Dense layers (odd) and Sliding Window layers (even)
// - Grouped Multi-Query Attention with group size of 8
// - RoPE positional encoding supporting up to 128k context length
// - MXFP4 quantization (4.25 bits per param) enabling 120B model on 80GB GPU
//
// CPU Requirements:
// - Minimum: SSE4.2 (for basic MXFP4 dequantization operations)
// - Recommended: AVX2 + F16C (for vectorized MXFP4 operations)
// - Optional: AVX_VNNI (Alderlake+) provides ~10-20% speedup for INT8 dot products
//   Note: AVX_VNNI requires GCC 11+, not available with CUDA 11.4 + GCC 10 builds
// - This code runs on any modern x86_64 CPU (Haswell 2013+), older CPUs may be slower
//
// Memory Layout:
// - MXFP4: 4-bit mantissa + shared 8-bit exponent per 32-element block
// - Storage: 17 bytes per 32 elements (1 byte scale + 16 bytes values)
// - Dequantization happens on-the-fly during inference
package gptoss

import (
	"cmp"
	"math"
	"strings"

	"github.com/ollama/ollama/fs"
	"github.com/ollama/ollama/kvcache"
	"github.com/ollama/ollama/ml"
	"github.com/ollama/ollama/ml/nn"
	"github.com/ollama/ollama/ml/nn/fast"
	"github.com/ollama/ollama/ml/nn/rope"
	"github.com/ollama/ollama/model"
	"github.com/ollama/ollama/model/input"
)

// Transformer is the main GPT-OSS model structure implementing the MoE architecture.
// It contains token embeddings, multiple transformer blocks with alternating attention patterns,
// output normalization, and the final output projection layer.
type Transformer struct {
	model.Base
	model.BytePairEncoding

	TokenEmbedding    *nn.Embedding      `gguf:"token_embd"`
	TransformerBlocks []TransformerBlock `gguf:"blk"`
	OutputNorm        *nn.RMSNorm        `gguf:"output_norm"`
	Output            *nn.Linear         `gguf:"output,alt:token_embd"`

	Options
}

// Forward implements model.Model and performs a forward pass through the entire model.
// This processes input tokens through all transformer layers to generate output logits.
//
// The alternating attention pattern (odd layers = dense, even layers = sliding window)
// provides a balance between global context understanding and computational efficiency.
//
// Processing flow:
// 1. Convert input token IDs to embeddings
// 2. Pass through all transformer blocks (each with attention + MoE MLP)
// 3. Apply output normalization
// 4. Project to vocabulary size for next token prediction
func (m *Transformer) Forward(ctx ml.Context, batch input.Batch) (ml.Tensor, error) {
	// Convert token IDs to dense vector embeddings
	hiddenStates := m.TokenEmbedding.Forward(ctx, batch.Inputs)
	positions := ctx.Input().FromInts(batch.Positions, len(batch.Positions))

	// Process through all transformer blocks sequentially
	for i, block := range m.TransformerBlocks {
		m.Cache.SetLayer(i)
		if c, ok := m.Cache.(*kvcache.WrapperCache); ok {
			// Even-indexed layers (0, 2, 4, ...) use sliding window attention (local context)
			// Odd-indexed layers (1, 3, 5, ...) use dense attention (global context)
			// This alternating pattern reduces memory while maintaining model quality
			c.SetLayerType(i % 2)
		}

		var outputs ml.Tensor
		if i == len(m.TransformerBlocks)-1 {
			outputs = batch.Outputs
		}

		hiddenStates = block.Forward(ctx, hiddenStates, positions, outputs, m.Cache, &m.Options)
	}

	// Apply final RMS normalization before output projection
	hiddenStates = m.OutputNorm.Forward(ctx, hiddenStates, m.eps)
	return m.Output.Forward(ctx, hiddenStates), nil
}

func (m *Transformer) Shift(ctx ml.Context, layer int, key, shift ml.Tensor) (ml.Tensor, error) {
	return fast.RoPE(ctx, key, shift, m.headDim(), m.ropeBase, 1./m.ropeScale, m.RoPEOptions()...), nil
}

type Options struct {
	hiddenSize,
	numHeads,
	numKVHeads,
	keyLength,
	valueLength,
	numExperts,
	numExpertsUsed,
	originalContextLength int

	eps,
	ropeBase,
	ropeScale float32
}

func (o Options) RoPEOptions() []func(*rope.Options) {
	return []func(*rope.Options){
		rope.WithTypeNeoX(),
		rope.WithOriginalContextLength(o.originalContextLength),
		rope.WithExtrapolationFactor(1.),
		// NOTE: ggml sets this implicitly so there's no need to set it here
		// rope.WithAttentionFactor(0.1*float32(math.Log(float64(o.ropeScale))) + 1.0),
	}
}

func (o Options) headDim() int {
	return cmp.Or(o.keyLength, o.valueLength, o.hiddenSize/o.numHeads)
}

type TransformerBlock struct {
	Attention *AttentionBlock
	MLP       *MLPBlock
}

func (d *TransformerBlock) Forward(ctx ml.Context, hiddenStates, positions, outputs ml.Tensor, cache kvcache.Cache, opts *Options) ml.Tensor {
	hiddenStates = d.Attention.Forward(ctx, hiddenStates, positions, cache, opts)
	if outputs != nil {
		hiddenStates = hiddenStates.Rows(ctx, outputs)
	}

	hiddenStates = d.MLP.Forward(ctx, hiddenStates, opts)
	return hiddenStates
}

type AttentionBlock struct {
	Norm *nn.RMSNorm `gguf:"attn_norm"`

	QKV *nn.Linear `gguf:"attn_qkv"`

	Query *nn.Linear `gguf:"attn_q"`
	Key   *nn.Linear `gguf:"attn_k"`
	Value *nn.Linear `gguf:"attn_v"`

	Output *nn.Linear `gguf:"attn_out,alt:attn_output"`
	Sinks  ml.Tensor  `gguf:"attn_sinks,alt:attn_sinks.weight"`
}

func (attn *AttentionBlock) Forward(ctx ml.Context, hiddenStates, positions ml.Tensor, cache kvcache.Cache, opts *Options) ml.Tensor {
	batchSize := hiddenStates.Dim(1)

	residual := hiddenStates
	hiddenStates = attn.Norm.Forward(ctx, hiddenStates, opts.eps)

	var query, key, value ml.Tensor
	if attn.QKV != nil {
		qkv := attn.QKV.Forward(ctx, hiddenStates)

		// query = qkv[..., : num_attention_heads * head_dim].reshape(batch_size, num_attention_heads, head_dim)
		query = qkv.View(ctx,
			0,
			opts.headDim(), qkv.Stride(0)*opts.headDim(),
			opts.numHeads, qkv.Stride(1),
			batchSize,
		)

		// key = qkv[..., num_attention_heads * head_dim:(num_attention_heads + num_key_value_heads) * head_dim].reshape(batch_size, num_key_value_heads, head_dim)
		key = qkv.View(ctx,
			qkv.Stride(0)*opts.headDim()*opts.numHeads,
			opts.headDim(), qkv.Stride(0)*opts.headDim(),
			opts.numKVHeads, qkv.Stride(1),
			batchSize,
		)

		// value = qkv[..., (num_attention_heads  + num_key_value_heads) * head_dim:].reshape(batch_size, num_key_value_heads, head_dim)
		value = qkv.View(ctx,
			qkv.Stride(0)*opts.headDim()*(opts.numHeads+opts.numKVHeads),
			opts.headDim(), qkv.Stride(0)*opts.headDim(),
			opts.numKVHeads, qkv.Stride(1),
			batchSize,
		)
	} else {
		query = attn.Query.Forward(ctx, hiddenStates)
		query = query.Reshape(ctx, opts.headDim(), opts.numHeads, batchSize)

		key = attn.Key.Forward(ctx, hiddenStates)
		key = key.Reshape(ctx, opts.headDim(), opts.numKVHeads, batchSize)

		value = attn.Value.Forward(ctx, hiddenStates)
		value = value.Reshape(ctx, opts.headDim(), opts.numKVHeads, batchSize)
	}

	query = fast.RoPE(ctx, query, positions, opts.headDim(), opts.ropeBase, 1./opts.ropeScale, opts.RoPEOptions()...)
	key = fast.RoPE(ctx, key, positions, opts.headDim(), opts.ropeBase, 1./opts.ropeScale, opts.RoPEOptions()...)

	attention := nn.AttentionWithSinks(ctx, query, key, value, attn.Sinks, 1/math.Sqrt(float64(opts.headDim())), cache)
	attention = attention.Reshape(ctx, attention.Dim(0)*attention.Dim(1), batchSize)
	return attn.Output.Forward(ctx, attention).Add(ctx, residual)
}

// MLPBlock implements the Mixture-of-Experts (MoE) feed-forward layer.
// This is the key to GPT-OSS's efficiency - it only activates a subset of experts per token.
//
// MoE Architecture:
// - Router network selects top-k experts for each token (typically k=2)
// - Only selected experts process the token (sparse activation)
// - Example: 120B model has 113B expert parameters but only activates ~5B per token
// - This provides large model capacity with smaller computational cost
//
// CPU Performance Notes:
// - Router: Small matrix multiply (no special CPU requirements)
// - Expert weights: Stored in MXFP4 format (dequantized on-the-fly)
// - MXFP4 dequantization benefits from AVX2 vectorization
// - AVX_VNNI (Alderlake+) provides 10-20% speedup but not required
type MLPBlock struct {
	Norm   *nn.RMSNorm `gguf:"ffn_norm,alt:post_attention_norm"`
	Router *nn.Linear  `gguf:"ffn_gate_inp"` // Selects which experts to use

	GateUp *nn.LinearBatch `gguf:"ffn_gate_up_exps"` // Interleaved gate+up weights (memory efficient)

	Gate *nn.LinearBatch `gguf:"ffn_gate_exps"` // Gate projection (alternative layout)
	Up   *nn.LinearBatch `gguf:"ffn_up_exps"`   // Up projection (alternative layout)

	Down *nn.LinearBatch `gguf:"ffn_down_exps"` // Down projection (all experts)
}

// Forward processes the input through the MoE layer with expert routing.
//
// Processing steps:
// 1. Normalize input
// 2. Router selects top-k experts based on input
// 3. Compute routing weights (softmax over selected experts)
// 4. Process input through selected experts only
// 5. Combine expert outputs weighted by routing scores
// 6. Add residual connection
//
// CPU Performance: The expert matrix multiplications use MXFP4 weights which are
// dequantized during computation. AVX2 CPUs (2013+) will vectorize this efficiently.
func (mlp *MLPBlock) Forward(ctx ml.Context, hiddenStates ml.Tensor, opts *Options) ml.Tensor {
	hiddenDim, sequenceLength, batchSize := hiddenStates.Dim(0), hiddenStates.Dim(1), hiddenStates.Dim(2)

	residual := hiddenStates
	hiddenStates = mlp.Norm.Forward(ctx, hiddenStates, opts.eps)

	hiddenStates = hiddenStates.Reshape(ctx, hiddenDim, sequenceLength*batchSize)
	// Router computes affinity scores for all experts
	routingWeights := mlp.Router.Forward(ctx, hiddenStates)

	// Select top-k experts with highest scores (sparse activation)
	// Example: If 16 experts and k=2, only 2 experts process each token
	selectedExperts := routingWeights.TopK(ctx, opts.numExpertsUsed)
	routingWeights = routingWeights.Reshape(ctx, 1, opts.numExperts, sequenceLength*batchSize).Rows(ctx, selectedExperts)
	// Normalize routing weights so they sum to 1 (softmax over selected experts)
	routingWeights = routingWeights.Reshape(ctx, opts.numExpertsUsed, sequenceLength*batchSize).Softmax(ctx)
	routingWeights = routingWeights.Reshape(ctx, 1, opts.numExpertsUsed, sequenceLength*batchSize)

	hiddenStates = hiddenStates.Reshape(ctx, hiddenStates.Dim(0), 1, hiddenStates.Dim(1))

	// Process through selected experts
	var gate, up ml.Tensor
	if mlp.GateUp != nil {
		// Interleaved layout: gate and up weights are stored together for memory efficiency
		hiddenStates = mlp.GateUp.Forward(ctx, hiddenStates, selectedExperts)
		hiddenStates = hiddenStates.Reshape(ctx, 2, hiddenStates.Dim(0)/2, hiddenStates.Dim(1), hiddenStates.Dim(2))

		dimStride := []int{hiddenStates.Dim(0) / 2, hiddenStates.Stride(1), hiddenStates.Dim(1), hiddenStates.Stride(2), hiddenStates.Dim(2), hiddenStates.Stride(3), hiddenStates.Dim(3)}

		// Split interleaved gate/up into separate tensors
		gate = hiddenStates.View(ctx, 0, dimStride...)
		gate = gate.Contiguous(ctx, gate.Dim(0)*gate.Dim(1), gate.Dim(2), gate.Dim(3))

		up = hiddenStates.View(ctx, hiddenStates.Stride(0), dimStride...)
		up = up.Contiguous(ctx, up.Dim(0)*up.Dim(1), up.Dim(2), up.Dim(3))
	} else {
		// Separate layout: gate and up weights stored independently
		gate = mlp.Gate.Forward(ctx, hiddenStates, selectedExperts)
		up = mlp.Up.Forward(ctx, hiddenStates, selectedExperts)
	}

	// Apply SwiGLU activation with alpha limiting for numerical stability
	// SwiGLU: gate.silu() * up, where silu(x) = x * sigmoid(x)
	// Alpha limit prevents gradient explosion during training
	hiddenStates = gate.SILUAlphaLimit(ctx, up, 1.702, 7)

	// Project back down to hidden dimension through each expert's down projection
	experts := mlp.Down.Forward(ctx, hiddenStates, selectedExperts)
	// Weight each expert's output by its routing score
	experts = experts.Mul(ctx, routingWeights)

	// Combine all expert outputs (weighted sum)
	nextStates := experts.View(ctx, 0, experts.Dim(0), experts.Stride(2), experts.Dim(2))
	for i := 1; i < opts.numExpertsUsed; i++ {
		nextStates = nextStates.Add(ctx, experts.View(ctx, i*experts.Stride(1), experts.Dim(0), experts.Stride(2), experts.Dim(2)))
	}

	// Add residual connection for gradient flow
	return nextStates.Add(ctx, residual)
}

// New creates a new GPT-OSS Transformer model from a GGUF configuration.
// This initializes all model components including:
// - Transformer blocks (attention + MoE MLP layers)
// - Byte-pair encoding tokenizer
// - Dual cache system (sliding window for even layers, causal for odd layers)
func New(c fs.Config) (model.Model, error) {
	m := Transformer{
		TransformerBlocks: make([]TransformerBlock, c.Uint("block_count")),
		BytePairEncoding: model.NewBytePairEncoding(
			&model.Vocabulary{
				Values: c.Strings("tokenizer.ggml.tokens"),
				Types:  c.Ints("tokenizer.ggml.token_type"),
				Merges: c.Strings("tokenizer.ggml.merges"),
				AddBOS: c.Bool("tokenizer.ggml.add_bos_token", false),
				BOS:    []int32{int32(c.Uint("tokenizer.ggml.bos_token_id"))},
				AddEOS: c.Bool("tokenizer.ggml.add_eos_token", false),
				EOS: append(
					[]int32{int32(c.Uint("tokenizer.ggml.eos_token_id"))},
					c.Ints("tokenizer.ggml.eos_token_ids")...,
				),
			},
			// GPT-4 tokenizer pattern: handles words, numbers, punctuation, and whitespace
			strings.Join([]string{
				`[^\r\n\p{L}\p{N}]?[\p{Lu}\p{Lt}\p{Lm}\p{Lo}\p{M}]*[\p{Ll}\p{Lm}\p{Lo}\p{M}]+(?i:'s|'t|'re|'ve|'m|'ll|'d)?`,
				`[^\r\n\p{L}\p{N}]?[\p{Lu}\p{Lt}\p{Lm}\p{Lo}\p{M}]+[\p{Ll}\p{Lm}\p{Lo}\p{M}]*(?i:'s|'t|'re|'ve|'m|'ll|'d)?`,
				`\p{N}{1,3}`,
				` ?[^\s\p{L}\p{N}]+[\r\n/]*`,
				`\s*[\r\n]+`,
				`\s+(?!\S)`,
				`\s+`,
			}, "|"),
		),
		Options: Options{
			hiddenSize:            int(c.Uint("embedding_length")),
			numHeads:              int(c.Uint("attention.head_count")),
			numKVHeads:            int(c.Uint("attention.head_count_kv")), // Grouped multi-query attention
			keyLength:             int(c.Uint("attention.key_length")),
			valueLength:           int(c.Uint("attention.value_length")),
			numExperts:            int(c.Uint("expert_count")),            // Total number of experts per layer
			numExpertsUsed:        int(c.Uint("expert_used_count")),      // Number of experts activated per token (k)
			eps:                   c.Float("attention.layer_norm_rms_epsilon"),
			ropeBase:              c.Float("rope.freq_base"),
			ropeScale:             c.Float("rope.scaling.factor", 1.),
			originalContextLength: int(c.Uint("rope.scaling.original_context_length")),
		},
	}

	// Create dual cache system:
	// - Sliding window cache: For even layers (local attention with fixed window size)
	// - Causal cache: For odd layers (full attention over all previous tokens)
	// This hybrid approach balances memory usage with model quality
	m.Cache = kvcache.NewWrapperCache(
		kvcache.NewSWAMemCache(int32(c.Uint("attention.sliding_window")), 4096, m.Shift),
		kvcache.NewCausalCache(m.Shift),
	)
	return &m, nil
}

func init() {
	model.Register("gptoss", New)
	model.Register("gpt-oss", New)
}
