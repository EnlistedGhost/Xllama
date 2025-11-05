// Package convert handles conversion of HuggingFace GPT-OSS models to GGUF format.
//
// MXFP4 Format:
// MXFP4 (Microscaling FP4) is a 4.25 bits-per-weight quantization format that stores:
// - 4-bit mantissas for each weight
// - Shared 8-bit exponent (scale) per 32-weight block
// - Total: 17 bytes per 32 weights (1 scale + 16 mantissa bytes)
//
// Benefits:
// - 4.25 bpw is ~4x smaller than FP16 (16 bpw)
// - Enables 120B model on 80GB GPU (vs 240GB for FP16)
// - Better quality than pure 4-bit quantization due to shared exponent
// - Hardware-friendly format (efficient dequantization on modern CPUs/GPUs)
//
// Conversion Process:
// 1. Read HuggingFace .blocks (4-bit mantissas) and .scales (8-bit exponents)
// 2. Repack mantissas from HF layout to GGML layout (bit shuffling)
// 3. Concatenate scales and blocks into GGML's expected format
// 4. Write to GGUF file for efficient loading by Ollama
package convert

import (
	"bytes"
	"cmp"
	"encoding/binary"
	"io"
	"slices"
	"strings"

	"github.com/ollama/ollama/fs/ggml"
	"github.com/pdevine/tensor"
	"github.com/pdevine/tensor/native"
)

// gptossModel represents the configuration of a GPT-OSS model from HuggingFace.
// This structure maps directly to the config.json fields in HF model repositories.
type gptossModel struct {
	ModelParameters
	HiddenLayers          uint32  `json:"num_hidden_layers"`
	MaxPositionEmbeddings uint32  `json:"max_position_embeddings"`
	HiddenSize            uint32  `json:"hidden_size"`
	IntermediateSize      uint32  `json:"intermediate_size"`
	AttentionHeads        uint32  `json:"num_attention_heads"`
	KeyValueHeads         uint32  `json:"num_key_value_heads"`
	HeadDim               uint32  `json:"head_dim"`
	Experts               uint32  `json:"num_experts"`
	LocalExperts          uint32  `json:"num_local_experts"`
	ExpertsPerToken       uint32  `json:"experts_per_token"`
	RMSNormEpsilon        float32 `json:"rms_norm_eps"`
	InitialContextLength  uint32  `json:"initial_context_length"`
	RopeTheta             float32 `json:"rope_theta"`
	RopeScalingFactor     float32 `json:"rope_scaling_factor"`
	RopeScaling           struct {
		Factor float32 `json:"factor"`
	} `json:"rope_scaling"`
	SlidingWindow uint32 `json:"sliding_window"`
}

var _ ModelConverter = (*gptossModel)(nil)

func (m *gptossModel) KV(t *Tokenizer) ggml.KV {
	kv := m.ModelParameters.KV(t)
	kv["general.architecture"] = "gptoss"
	kv["general.file_type"] = uint32(4)
	kv["gptoss.context_length"] = cmp.Or(m.MaxPositionEmbeddings, uint32(m.RopeScalingFactor*float32(m.InitialContextLength)))
	kv["gptoss.block_count"] = m.HiddenLayers
	kv["gptoss.embedding_length"] = m.HiddenSize
	kv["gptoss.feed_forward_length"] = m.IntermediateSize
	kv["gptoss.expert_count"] = cmp.Or(m.Experts, m.LocalExperts)
	kv["gptoss.expert_used_count"] = m.ExpertsPerToken
	kv["gptoss.attention.head_count"] = m.AttentionHeads
	kv["gptoss.attention.head_count_kv"] = m.KeyValueHeads
	kv["gptoss.attention.key_length"] = m.HeadDim
	kv["gptoss.attention.value_length"] = m.HeadDim
	kv["gptoss.attention.layer_norm_rms_epsilon"] = cmp.Or(m.RMSNormEpsilon, 1e-5)
	kv["gptoss.attention.sliding_window"] = m.SlidingWindow
	kv["gptoss.rope.freq_base"] = m.RopeTheta
	kv["gptoss.rope.scaling.factor"] = cmp.Or(m.RopeScalingFactor, m.RopeScaling.Factor)
	kv["gptoss.rope.scaling.original_context_length"] = m.InitialContextLength
	kv["tokenizer.ggml.bos_token_id"] = uint32(199998) // <|startoftext|>
	kv["tokenizer.ggml.add_bos_token"] = false
	kv["tokenizer.ggml.eos_token_id"] = uint32(199999) // <|endoftext|>
	kv["tokenizer.ggml.eos_token_ids"] = []int32{
		199999, /* <|endoftext|> */
		200002, /* <|return|> */
		200012, /* <|call|> */
	}
	kv["tokenizer.ggml.add_eos_token"] = false
	return kv
}

func (m *gptossModel) Tensors(ts []Tensor) []*ggml.Tensor {
	var out []*ggml.Tensor
	mxfp4s := make(map[string]*mxfp4)
	for _, t := range ts {
		if strings.HasSuffix(t.Name(), ".blocks") || strings.HasSuffix(t.Name(), ".scales") {
			dot := strings.LastIndex(t.Name(), ".")
			name, suffix := t.Name()[:dot], t.Name()[dot+1:]
			if _, ok := mxfp4s[name]; !ok {
				mxfp4s[name] = &mxfp4{}
			}

			switch suffix {
			case "blocks":
				mxfp4s[name].blocks = t
			case "scales":
				mxfp4s[name].scales = t
			}
		} else if strings.HasSuffix(t.Name(), "gate_up_exps.bias") {
			// gate_up_exps is interleaved, need to split into gate_exps and up_exps
			// e.g. gate_exps, up_exps = gate_up_exps[:, 0::2, ...], gate_up_exps[:, 1::2, ...]
			out = append(out, slices.Collect(splitDim(t, 1,
				split{
					Replacer: strings.NewReplacer("gate_up_exps", "gate_exps"),
					slices:   []tensor.Slice{nil, tensor.S(0, int(t.Shape()[1]), 2)},
				},
				split{
					Replacer: strings.NewReplacer("gate_up_exps", "up_exps"),
					slices:   []tensor.Slice{nil, tensor.S(1, int(t.Shape()[1]), 2)},
				},
			))...)
		} else {
			out = append(out, &ggml.Tensor{
				Name:     t.Name(),
				Kind:     t.Kind(),
				Shape:    t.Shape(),
				WriterTo: t,
			})
		}
	}

	for name, mxfp4 := range mxfp4s {
		dims := mxfp4.blocks.Shape()
		if strings.Contains(name, "ffn_down_exps") {
			out = append(out, &ggml.Tensor{
				Name:     name + ".weight",
				Kind:     uint32(ggml.TensorTypeMXFP4),
				Shape:    []uint64{dims[0], dims[1], dims[2] * dims[3] * 2},
				WriterTo: mxfp4,
			})
		} else if strings.Contains(name, "ffn_gate_up_exps") {
			// gate_up_exps is interleaved, need to split into gate_exps and up_exps
			// e.g. gate_exps, up_exps = gate_up_exps[:, 0::2, ...], gate_up_exps[:, 1::2, ...]
			out = append(out, &ggml.Tensor{
				Name:     strings.Replace(name, "gate_up", "gate", 1) + ".weight",
				Kind:     uint32(ggml.TensorTypeMXFP4),
				Shape:    []uint64{dims[0], dims[1] / 2, dims[2] * dims[3] * 2},
				WriterTo: mxfp4.slice(1, 0, int(dims[1]), 2),
			}, &ggml.Tensor{
				Name:     strings.Replace(name, "gate_up", "up", 1) + ".weight",
				Kind:     uint32(ggml.TensorTypeMXFP4),
				Shape:    []uint64{dims[0], dims[1] / 2, dims[2] * dims[3] * 2},
				WriterTo: mxfp4.slice(1, 1, int(dims[1]), 2),
			})
		}
	}

	return out
}

func (m *gptossModel) Replacements() []string {
	var replacements []string
	if m.MaxPositionEmbeddings > 0 {
		// hf flavored model
		replacements = []string{
			"lm_head", "output",
			"model.embed_tokens", "token_embd",
			"model.layers", "blk",
			"input_layernorm", "attn_norm",
			"self_attn.q_proj", "attn_q",
			"self_attn.k_proj", "attn_k",
			"self_attn.v_proj", "attn_v",
			"self_attn.o_proj", "attn_out",
			"self_attn.sinks", "attn_sinks",
			"post_attention_layernorm", "ffn_norm",
			"mlp.router", "ffn_gate_inp",
			"mlp.experts.gate_up_proj_", "ffn_gate_up_exps.",
			"mlp.experts.down_proj_", "ffn_down_exps.",
			"model.norm", "output_norm",
		}
	} else {
		replacements = []string{
			// noop replacements so other replacements will not be applied
			".blocks", ".blocks",
			".scales", ".scales",
			// real replacements
			"block", "blk",
			"attn.norm", "attn_norm",
			"attn.qkv", "attn_qkv",
			"attn.sinks", "attn_sinks",
			"attn.out", "attn_out",
			"mlp.norm", "ffn_norm",
			"mlp.gate", "ffn_gate_inp",
			"mlp.mlp1_", "ffn_gate_up_exps.",
			"mlp.mlp2_", "ffn_down_exps.",
			"embedding", "token_embd",
			"norm", "output_norm",
			"unembedding", "output",
			"scale", "weight",
		}
	}
	return replacements
}

// mxfp4 handles conversion of MXFP4-quantized weights from HuggingFace to GGML format.
//
// HuggingFace MXFP4 Layout:
// - .blocks: 4-bit mantissas packed as uint8 (2 mantissas per byte)
// - .scales: 8-bit exponents (one per 32-element block)
//
// GGML MXFP4 Layout (what Ollama expects):
// - Concatenated: [scale byte][16 bytes of repacked mantissas] per block
// - Mantissas are bit-shuffled for efficient SIMD dequantization
//
// This conversion happens once during model import, not during inference.
// CPU requirements: None special - this is simple bit manipulation.
type mxfp4 struct {
	slices []tensor.Slice // Optional slicing (for splitting interleaved weights)

	blocks, scales Tensor // Source tensors from HuggingFace
}

// slice creates a view into the MXFP4 tensor for a specific dimension range.
// Used to split interleaved gate_up_exps into separate gate_exps and up_exps tensors.
func (m *mxfp4) slice(dim, start, end, step int) *mxfp4 {
	slice := slices.Repeat([]tensor.Slice{nil}, len(m.blocks.Shape()))
	slice[dim] = tensor.S(start, end, step)
	return &mxfp4{
		slices: slice,
		blocks: m.blocks,
		scales: m.scales,
	}
}

// WriteTo converts MXFP4 weights from HuggingFace format to GGML format and writes to output.
//
// Conversion steps:
// 1. Read 4-bit mantissa blocks from HuggingFace format
// 2. Repack mantissas using bit shuffling for GGML's SIMD-friendly layout
// 3. Read 8-bit scale values
// 4. Concatenate scales and repacked blocks
// 5. Apply any slicing (for interleaved weight splitting)
// 6. Write in little-endian byte order
//
// The bit shuffling (lines 233-237) transforms the mantissa layout to optimize
// CPU SIMD dequantization performance. This is a one-time cost during conversion.
func (m *mxfp4) WriteTo(w io.Writer) (int64, error) {
	// Read and repack mantissa blocks
	var b bytes.Buffer
	if _, err := m.blocks.WriteTo(&b); err != nil {
		return 0, err
	}

	blocksDims := make([]int, len(m.blocks.Shape()))
	for i, d := range m.blocks.Shape() {
		blocksDims[i] = int(d)
	}

	bts := b.Bytes()
	var tmp [16]byte
	// Repack mantissas from HuggingFace layout to GGML layout
	// Process 16 bytes (32 mantissas, one block) at a time
	for i := 0; i < b.Len(); i += 16 {
		for j := range 8 {
			// Bit shuffling for SIMD efficiency
			// Transform: a1b2c3...x7y8z9 -> 71xa82yb93zc
			// This reordering allows efficient vectorized dequantization
			// HF packs mantissas sequentially, GGML interleaves them for SIMD lanes
			a, b := bts[i+j], bts[i+j+8]
			tmp[2*j+0] = (a & 0x0F) | (b << 4)
			tmp[2*j+1] = (a >> 4) | (b & 0xF0)
		}

		copy(bts[i:i+16], tmp[:])
	}

	var blocks tensor.Tensor = tensor.New(tensor.WithShape(blocksDims...), tensor.WithBacking(bts))

	// Read scale values (one 8-bit exponent per 32-weight block)
	var s bytes.Buffer
	if _, err := m.scales.WriteTo(&s); err != nil {
		return 0, err
	}

	scalesDims := slices.Repeat([]int{1}, len(m.blocks.Shape()))
	for i, d := range m.scales.Shape() {
		scalesDims[i] = int(d)
	}

	var scales tensor.Tensor = tensor.New(tensor.WithShape(scalesDims...), tensor.WithBacking(s.Bytes()))

	// Concatenate scales and blocks into GGML's expected format:
	// [scale_byte_0][16_mantissa_bytes_0][scale_byte_1][16_mantissa_bytes_1]...
	out, err := tensor.Concat(3, scales, blocks)
	if err != nil {
		return 0, err
	}

	// Apply slicing if needed (e.g., splitting interleaved gate_up_exps)
	if len(m.slices) > 0 {
		out, err = out.Slice(m.slices...)
		if err != nil {
			return 0, err
		}
	}

	// Materialize the tensor (execute any pending lazy operations)
	out = tensor.Materialize(out)

	// Flatten to 1D for writing
	if err := out.Reshape(out.Shape().TotalSize()); err != nil {
		return 0, err
	}

	// Extract raw bytes
	u8s, err := native.VectorU8(out.(*tensor.Dense))
	if err != nil {
		return 0, err
	}

	// Write in little-endian format (x86/ARM standard)
	if err := binary.Write(w, binary.LittleEndian, u8s); err != nil {
		return 0, err
	}

	return int64(len(u8s)), nil
}
