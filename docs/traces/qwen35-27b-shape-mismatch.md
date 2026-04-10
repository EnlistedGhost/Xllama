# Trace: qwen3.5:27b tensor shape mismatch in attn_gate.weight

**Issue**: #57 — qwen3.5:27b fails to load: tensor shape mismatch
**Date**: 2026-04-10
**Error**: `check_tensor_dims: tensor 'blk.0.attn_gate.weight' has wrong shape; expected 5120, 5120, got 5120, 6144, 1, 1`

## Root Cause

`wqkv_gate` (the DeltaNet gating projection) is hardcoded as `{n_embd, n_embd}` but
the actual GGUF tensor is `{n_embd, ssm_d_inner}`. For qwen3.5:2b these happen to be
equal (`n_embd == ssm_d_inner`), but for qwen3.5:27b they differ:
- `n_embd` = 5120
- `ssm_d_inner` = 6144

## Call Flow: Engine Selection → llama.cpp → Error

```
NewLlamaServer()                                      # llm/server.go:148
  ├── OllamaEngineRequired("qwen35") → true           # fs/ggml/ggml.go:253
  ├── model.NewTextProcessor(modelPath)                # llm/server.go:154
  │     └── modelForArch("qwen35") → ErrUnsupportedModel  # no Go model registered
  ├── slog.Debug("switching to compatibility mode")    # llm/server.go:160
  └── llama.LoadModelFromFile(modelPath, ...)          # llm/server.go:164 (FALLBACK)
        └── llama_model_load_from_file_impl()
              └── create_tensor("blk.0.attn_gate.weight", {n_embd, n_embd})
                    └── check_tensor_dims() → MISMATCH      # llama-model-loader.cpp:762
                          expected {5120, 5120}
                          got      {5120, 6144}
                          THROWS → "unable to load model"
```

**Note**: qwen35 IS in `OllamaEngineRequired()` but there is no Go model implementation
(`model/models/qwen35/` does not exist). The new engine returns `ErrUnsupportedModel`,
so it falls back to the old llama.cpp runner.

## Why qwen3.5:2b Works But 27b Doesn't

For qwen3.5:2b: `n_embd = ssm_d_inner` (both equal), so `{n_embd, n_embd}` matches the GGUF.
For qwen3.5:27b: `ssm_d_inner = 6144 ≠ n_embd = 5120`, so the hardcoded shape is wrong.

## Tensor Usage in Graph Builder

```
build_qkvz(cur, il)                                   # llama-model.cpp:12424
  ├── qkv_mixed = wqkv @ cur     → [conv_dim, n_tokens]
  └── z         = wqkv_gate @ cur → [ssm_d_inner, n_tokens]   # line 12432

z flows to:
  build_norm_gated(attn_out_2d, ssm_norm, z_2d, il)   # line 12641
    z_2d = reshape(z, [head_v_dim, num_v_heads * n_tokens])
    → z must have total elements = ssm_d_inner * n_tokens
    → wqkv_gate shape must be {n_embd, ssm_d_inner}
```

## Fix

Line 3382 in `llama/llama.cpp/src/llama-model.cpp`:

```cpp
// BEFORE (wrong for 27b):
layer.wqkv_gate = create_tensor(..., {n_embd, n_embd}, 0);

// AFTER (correct for all sizes):
layer.wqkv_gate = create_tensor(..., {n_embd, ssm_d_inner}, 0);
```

Where `ssm_d_inner` is already computed at line 3352:
```cpp
const int64_t ssm_d_inner = hparams.ssm_d_inner;
```

## Dimension Reference (qwen3.5 model sizes)

| Parameter | 2b (n_layer=24) | 27b |
|---|---|---|
| n_embd | (small) | 5120 |
| ssm_d_inner | = n_embd | 6144 |
| ssm_d_state | 128 | 128 |
| ssm_dt_rank (n_v_heads) | ? | 48 |
| ssm_n_group (n_k_heads) | ? | 8 |
| head_v_dim | ssm_d_inner/n_v_heads | 6144/48 = 128 |
| conv_dim | key_dim*2 + value_dim | head_k*n_k*2 + head_v*n_v = 128*8*2 + 128*48 = 8192 |

## Secondary Issue: No Go Model Implementation

qwen35 has no Go-side model (`model/models/qwen35/`), so it always falls back to
llama.cpp. This is a larger porting effort (DeltaNet layers, chunked attention, custom
GGML ops) tracked separately. The immediate fix is correcting the tensor shape in
llama.cpp.
