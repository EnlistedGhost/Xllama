# Trace: qwen3.5:27b fails to load and run

**Issue**: #57 — qwen3.5:27b fails to load: tensor shape mismatch
**Date**: 2026-04-10

## Two Bugs Found

1. **Bug 1 (fixed)**: `wqkv_gate` tensor shape hardcoded as `{n_embd, n_embd}`, should be `{n_embd, ssm_d_inner}`
2. **Bug 2 (open)**: Graph context memory pool too small — `GGML_ASSERT(obj_new) failed`

## Bug 1: Tensor Shape Mismatch

**Error**: `check_tensor_dims: tensor 'blk.0.attn_gate.weight' has wrong shape; expected 5120, 5120, got 5120, 6144, 1, 1`

**Root cause**: `wqkv_gate` (DeltaNet gating projection) is hardcoded as `{n_embd, n_embd}` but
the GGUF tensor is `{n_embd, ssm_d_inner}`. For qwen3.5:2b `n_embd == ssm_d_inner`, so it worked
by accident. For 27b they differ: `n_embd = 5120`, `ssm_d_inner = 6144`.

**Fix applied**: Line 3382 in `llama/llama.cpp/src/llama-model.cpp`:
```cpp
// BEFORE:
layer.wqkv_gate = create_tensor(..., {n_embd, n_embd}, 0);
// AFTER:
layer.wqkv_gate = create_tensor(..., {n_embd, ssm_d_inner}, 0);
```

### Tensor usage in graph builder

```
build_qkvz(cur, il)                                   # llama-model.cpp:12424
  ├── qkv_mixed = wqkv @ cur     → [conv_dim, n_tokens]
  └── z         = wqkv_gate @ cur → [ssm_d_inner, n_tokens]   # line 12432

z flows to:
  build_norm_gated(attn_out_2d, ssm_norm, z_2d, il)   # line 12641
    z_2d = reshape(z, [head_v_dim, num_v_heads * n_tokens])
    → z total elements = ssm_d_inner * n_tokens
    → wqkv_gate shape must be {n_embd, ssm_d_inner}
```

## Bug 2: Graph Context Memory Pool Overflow

**Error**: `ggml_new_object: not enough space in the context's memory pool (needed 6689312, available 6688944)`

After fixing Bug 1, the model loads weights successfully but crashes during graph reservation
(building the compute graph before first inference).

### What is the graph context?

Every GPU computation requires a plan (compute graph) built on CPU first:

```
CPU (manager)                          GPU (worker)
─────────────                          ────────────
Build compute graph:                   Weights loaded, waiting
  Layer 0: matmul → reshape → ...        CUDA0: 3492 MiB ✓
  Layer 1: matmul → reshape → ...        CUDA1: 3404 MiB ✓
  ...                                    CUDA2: 3382 MiB ✓
  Layer 48: matmul → ✗ CRASH             CUDA3: 3514 MiB ✓
  (368 bytes short)
                                       Never received the graph,
Send graph to GPU → NEVER REACHED      never ran inference
```

The graph context is a CPU-side memory pool (~6.4 MB) that stores tensor metadata
(operation type, dimensions, connections) — NOT the actual tensor data. It's the
blueprint, not the materials. Every framework (PyTorch, TensorFlow, GGML) builds
graphs on CPU before dispatching to GPU.

### Why it overflows

The pool size is determined by `graph_max_nodes`:

```cpp
// llama-graph.cpp:468
buf_compute_meta.resize(ggml_tensor_overhead() * max_nodes + ggml_graph_overhead());
```

```cpp
// llama-context.cpp:1363
uint32_t llama_context::graph_max_nodes() const {
    return std::max<uint32_t>(16384u, 8u * model.n_tensors());
}
```

- `n_tensors = 1307` → `8 * 1307 = 10456`
- `max(16384, 10456) = 16384` nodes
- Pool = `16384 * ~408 bytes = ~6.7 MB`

The 16384 minimum was set for qwen3.5:2b (24 layers). But 27b has **64 layers**,
and each DeltaNet layer creates many intermediate tensors in `build_delta_net_chunking`
(reshapes, permutes, pads, cumsum, triangular solve, mul_mat, etc.). The graph
exceeds 16384 nodes by ~1 tensor (368 bytes).

### Backtrace

```
ggml_mul_mat()
  build_delta_net_chunking()               # llama-model.cpp
    build_layer_attn_linear()              # llama-model.cpp:12513
      llm_build_qwen35()                   # llama-model.cpp:12117
        llama_model::build_graph()         # llama-model.cpp
          llama_context::graph_reserve()   # llama-context.cpp:1372
```

### Fix needed

Increase minimum `graph_max_nodes` in `llama-context.cpp:1365`:
```cpp
// BEFORE:
return std::max<uint32_t>(16384u, 8u * model.n_tensors());
// AFTER:
return std::max<uint32_t>(24576u, 8u * model.n_tensors());
```

24576 gives ~50% headroom over the current limit, costing ~3.3 MB more CPU RAM.

## Call Flow: Full Loading Path

```
NewLlamaServer()                                      # llm/server.go:148
  ├── OllamaEngineRequired("qwen35") → true           # fs/ggml/ggml.go:253
  ├── model.NewTextProcessor(modelPath)                # llm/server.go:154
  │     └── modelForArch("qwen35") → ErrUnsupportedModel  # no Go model registered
  ├── slog.Debug("switching to compatibility mode")    # llm/server.go:160
  └── llama.LoadModelFromFile(modelPath, ...)          # llm/server.go:164 (FALLBACK)
        └── llama_model_load_from_file_impl()
              ├── [Bug 1] create_tensor("blk.0.attn_gate.weight", {n_embd, n_embd})
              │     └── check_tensor_dims() → MISMATCH
              │
              ├── [After fix] Tensors load successfully
              │     offloaded 64/65 layers to GPU (output layer kept on CPU)
              │     CUDA0-3: ~3.4 GiB each
              │
              └── llama_init_from_model()
                    └── graph_reserve()
                          └── llm_build_qwen35()
                                └── build_delta_net_chunking()
                                      └── [Bug 2] ggml_mul_mat() → pool exhausted
                                            needed 6689312, available 6688944
```

## GPU Memory Layout (from container logs)

```
4x Tesla K80, compute capability 3.7
System RAM: 31.1 GiB (26.1 GiB free)

Model: qwen35, 27.78B params, Q4_K_M, 16.21 GiB file
  n_embd = 5120, n_layer = 64, n_head = 24
  ssm_d_inner = 6144, ssm_d_state = 128, ssm_dt_rank = 48, ssm_n_group = 16
  48 DeltaNet layers (recurrent), 16 full attention layers

Offload: 64/65 layers to GPU
  CUDA0: 3492 MiB weights + 64 MiB KV + 37 MiB RS = ~3593 MiB
  CUDA1: 3404 MiB weights + 64 MiB KV + 37 MiB RS = ~3505 MiB
  CUDA2: 3382 MiB weights + 64 MiB KV + 37 MiB RS = ~3483 MiB
  CUDA3: 3514 MiB weights + 64 MiB KV + 37 MiB RS = ~3588 MiB
  CPU:    682 MiB (output layer) + 995 MiB (CUDA_Host pinned)

Compute buffer: 5.5 GiB (temporary workspace, allocated on GPU during inference)
```

### Why 64/65 layers (not all 65)

`memory.required.full = 40.6 GiB` for all 65 layers, and `memory.available = 44.8 GiB`
total across 4 GPUs. It fits overall, but the memory estimator checks **per-GPU**:
each GPU has 11.2 GiB, and one GPU must hold its layer share (~3.5 GiB) + compute
buffer (5.5 GiB) + the output layer (995 MiB) simultaneously. That's ~10 GiB — tight.
Ollama keeps the output layer on CPU as a safety margin. This is normal and has
minimal performance impact (one matmul per forward pass on CPU).

## Model Parameters (from GGUF KV)

| Parameter | Value |
|---|---|
| architecture | qwen35 |
| n_embd | 5120 |
| n_layer | 64 |
| n_head | 24 |
| n_head_kv | per-layer: 0 (DeltaNet) or 4 (attention) |
| n_embd_head_k/v | 256 |
| n_ff | 17408 |
| ssm.inner_size | 6144 |
| ssm.state_size | 128 |
| ssm.time_step_rank | 48 |
| ssm.group_count | 16 |
| ssm.conv_kernel | 4 |
| full_attention_interval | 4 (every 4th layer is full attention) |
| context_length | 262144 |
| rope.freq_base | 10000000 |
| file_type | Q4_K_M (5.01 BPW) |
| file_size | 16.21 GiB |
| params | 27.78B |
| tensors | 1307 (851 text + 456 vision) |

## Dimension Reference

| Parameter | 2b (n_layer=24) | 27b (n_layer=64) |
|---|---|---|
| n_embd | (small) | 5120 |
| ssm_d_inner | = n_embd | 6144 |
| ssm_d_state | 128 | 128 |
| ssm_dt_rank (n_v_heads) | ? | 48 |
| ssm_n_group (n_k_heads) | ? | 16 |
| head_v_dim | ssm_d_inner/n_v_heads | 6144/48 = 128 |
| conv_dim | key_dim*2 + value_dim | 128*16*2 + 128*48 = 10240 |

## No Go Model Implementation

qwen35 has no Go-side model (`model/models/qwen35/` does not exist), so it always
falls back to llama.cpp. This is a larger porting effort (DeltaNet layers, chunked
attention, custom GGML ops) tracked separately.
