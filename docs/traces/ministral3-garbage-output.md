# Trace: ministral-3 garbage output — missing YaRN RoPE and position scaling

## Symptom
Model loads and generates tokens (no crash), but output is repetitive garbage:
`ral**ral**ral**ral**ral...` — the model gets stuck in a loop.

Also: `cudaMalloc failed: out of memory` during layer fitting (non-fatal, Ollama retries).

## Model architecture
- Architecture: `mistral3`, registered in `model/models/mistral3/model.go:167`
- 27 layers, Q4_K_M quantization, 3.8B params (~3GB on disk)
- Uses YaRN RoPE scaling (rope.scaling.type = "yarn" in GGUF)
- FlashAttention: false on K80 (compute 3.7)

## Root cause: missing YaRN RoPE options and position scaling

### What upstream has (model_text.go)
1. **`TextOptions`** includes YaRN fields: `ropeOrigPosEmbeddings`, `ropeScalingBeta`,
   `ropeBetaFast`, `ropeBetaSlow`, `ropeType`, `ropeMscale`, `ropeMscaleAllDim`,
   `ropeExtrapolation`
2. **`applyRotaryPositionEmbeddings()`** dispatches to `nn.RoPE()` with YaRN options
   when `ropeType == "yarn"`
3. **`getScale()`** computes position-dependent query scaling:
   `scale = 1 + beta * log(1 + floor(pos / origContextLen))`
4. **`SelfAttention.Forward()`** applies `positionsScale` to query:
   `q = q.Mul(ctx, positionsScale)` when `ropeOrigPosEmbeddings > 0`

### What our fork had
1. Basic `TextOptions` with only `ropeBase` and `ropeScale`
2. Direct `fast.RoPE()` call without any YaRN options
3. No `getScale()` function
4. No position scaling on query tensors

### Impact
Without YaRN RoPE, the rotary position embeddings use wrong frequency bases
for the model's expected context length scaling. Without position scaling,
attention weights are computed incorrectly. Both cause the model to lose
coherent generation and fall into repetitive loops.

## Call flow
```
Model.Forward()                                    # model.go:160
  ├── ctx.Input().FromInts(positions)              # position tensor
  ├── TextModel.getScale(ctx, positions)           # NEW: position scaling
  └── TextModel.Forward(inputs, pos, scale, ...)   # model_text.go:130
      ├── TokenEmbedding.Forward()                 # model_text.go:131
      └── for each Layer:
          └── Layer.Forward(hiddenState, pos, posScale, ...)  # model_text.go:109
              ├── AttentionNorm.Forward()
              ├── SelfAttention.Forward(pos, posScale)        # model_text.go:70
              │   ├── Query/Key/Value linear projections
              │   ├── applyRotaryPositionEmbeddings(q, pos)   # NEW: YaRN RoPE
              │   │   └── nn.RoPE(ctx, states, pos, dim, base, scale, yarnOpts...)
              │   ├── applyRotaryPositionEmbeddings(k, pos)   # NEW: YaRN RoPE
              │   ├── q.Mul(ctx, positionsScale)              # NEW: query scaling
              │   └── nn.Attention(q, k, v, scale, cache)
              │       └── SDPA fallback (no flash attention on K80)
              ├── residual connection
              └── MLP.Forward()
```

## Fix applied
- Added YaRN RoPE fields to `TextOptions` and GGUF config loading
- Added `applyRotaryPositionEmbeddings()` with YaRN dispatch
- Added `getScale()` for position-dependent query scaling
- Added `WithBetaFast`/`WithBetaSlow` to `ml/nn/rope/rope.go`
- Updated `Forward()` signatures to pass `positionsScale`

## Verified
- [x] Upstream uses same `NewCausalCache` (not sliding window) — confirmed
- [x] `rope.Options` struct already has YaRN fields in our fork
- [x] `ggml_rope_ext` already passes BetaFast/BetaSlow to C layer
- [x] `nn.RoPE` wrapper added in earlier commit delegates to fast.RoPE correctly
- [ ] Awaiting CI validation with TC-MODELS-013
