# Trace: ministral-3 memory usage on K80

## Environment
- 4× Tesla K80 GPUs (11.2 GiB free each)
- Model: ministral-3:3b (mistral3 architecture, Q4_K_M, 3.8B params, 27 layers)
- Parameters: BatchSize=512, KvSize=4096, FlashAttention=false

## Allocation sequence

Ollama tries GPU splits until one fits:

| Attempt | Split | Result |
|---------|-------|--------|
| 1 (fit) | 27 on GPU0 | Doesn't fit |
| 2 (fit) | 5/22 on GPU0/GPU1 | Fit OK |
| 3 (alloc) | 5/22 on GPU0/GPU1 | `cudaMalloc failed: 9199.70 MiB on device 1` |
| 4 (alloc) | 21/6 on GPU0/GPU2 | Retry |
| 5 (alloc) | 11/14/2 on GPU0/GPU1/GPU3 | Retry |
| 6 (alloc) | 12/12/3 on GPU0/GPU1/GPU2 | Retry |
| 7 (alloc) | 12/12/3 on GPU0/GPU1/GPU3 | **Success** |

Note: "fit" probes graph size without allocation; "alloc" actually allocates buffers.

## Final memory breakdown

| Resource | CUDA0 (12 layers) | CUDA1 (12 layers) | CUDA3 (3 layers) | CPU | Total |
|----------|-------|-------|-------|-----|-------|
| Weights | 797.5 MiB | 787.4 MiB | 1.2 GiB | 315.0 MiB | ~3.1 GiB |
| KV cache | 192.0 MiB | 192.0 MiB | 32.0 MiB | — | 416 MiB |
| Compute graph | 411.8 MiB | 400.0 MiB | **9.1 GiB** | 6.0 MiB | ~9.9 GiB |
| **Per GPU total** | ~1.4 GiB | ~1.4 GiB | ~10.3 GiB | ~321 MiB | **13.3 GiB** |

## Anomaly: 9.1 GiB compute graph on CUDA3

CUDA3 has only 3 layers (24-26: last 2 transformer layers + output head) but 9.1 GiB compute graph.

### Expected compute per layer (non-flash attention)
- QK^T intermediate: heads × batch × kv_size × sizeof(F32) = 24 × 512 × 4096 × 4 = ~192 MiB
- Softmax output: same size = ~192 MiB
- V×attention output: smaller
- Per layer total: ~400-500 MiB

3 layers should be ~1.2-1.5 GiB, not 9.1 GiB. The extra ~7.6 GiB is unexplained.

### Hypotheses
1. **Output projection activation**: `[vocab_size × batch]` in F32 — but 32768 × 512 × 4 = only 64 MiB
2. **GGML scheduler over-allocation**: `ggml_backend_sched_reserve` may allocate worst-case buffers for cross-GPU tensor transfers
3. **Non-flash softmax intermediate storage**: Without flash attention, full `[batch, heads, seq, seq]` attention matrix may be materialized — but only for the layers on that GPU
4. **Logit tensor**: Full vocab logits may be allocated on the GPU hosting the output layer

### TODO
- [ ] Add GGML debug logging to trace per-tensor allocations during graph reservation
- [ ] Compare with flash attention enabled (on a newer GPU) to measure the non-flash overhead
- [ ] Check if reducing BatchSize or KvSize shrinks the compute graph proportionally
- [ ] Profile with `nvprof` to see actual VRAM usage during inference

## Non-fatal cudaMalloc failure

The `cudaMalloc failed: out of memory` at attempt 3 is **expected behavior**. Ollama's scheduler probes GPU memory by attempting allocations and retrying with different splits. This is not a bug — the model loads successfully after finding a working split.

The simple judge flags this as a CUDA error because it pattern-matches `cudaMalloc failed` in Docker container logs. This is a false positive for the simple judge.
