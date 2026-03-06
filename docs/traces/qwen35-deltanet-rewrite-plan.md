# Plan: Qwen3.5 DeltaNet Rewrite

## Status
- [x] Phase 1: GGML ops (CPU backends) — committed on `issue-18-deltanet-ggml-ops`
- [ ] Phase 2: Port delta-net-base graph builder (#20)
- [ ] Phase 3: Rewrite qwen35.cpp to use DeltaNet builder (#21)
- [ ] Phase 4: CUDA backends for new ops (#19)
- [ ] Phase 5: Fix Go-side renderer (#15)

## Problem
The current qwen35.cpp uses `ggml_ssm_scan` (Mamba formula) for DeltaNet layers.
This produces garbage output because the formulas are fundamentally different.
See `docs/traces/qwen35-garbage-output.md` for the full 10-bug analysis.

## Approach
Port upstream llama.cpp PR #19468's approach. They do NOT use `ggml_ssm_scan`.
Instead they use explicit matrix ops via `delta-net-base.cpp`.

## Phase 2: Port delta-net-base graph builder (#20)

### What to port
Upstream files:
- `src/llama-graph-delta-net.cpp` -> our `ml/backend/ggml/ggml/src/llama-graph-delta-net.cpp`
- `src/llama-graph-delta-net.h` -> our `ml/backend/ggml/ggml/src/llama-graph-delta-net.h`

Wait — upstream puts these in llama.cpp's model code, not in ggml.
Check exact location in our fork's structure.

### Key functions
1. `build_delta_net_autoregressive(q, k, v, gate, beta, state, scale)`
   - Single-token decode path
   - Formula:
     ```
     gate_exp = exp(gate)                    # decay
     state = state * gate_exp                # apply decay
     d = (v - state^T @ k) * sigmoid(beta)  # delta rule
     state = state + k * d^T                # rank-1 update
     output = state^T @ q * scale           # readout
     ```

2. `build_delta_net_chunking(q, k, v, gate, beta, state, scale, chunk_size=64)`
   - Multi-token prefill path
   - Uses chunked processing with:
     - L2-normalized Q/K within chunks
     - Cumulative decay via `ggml_cumsum`
     - Triangular attention mask via `ggml_tri`
     - Triangular solve via `ggml_solve_tri`
     - Inter-chunk state propagation

### New GGML ops used (from Phase 1)
- `ggml_softplus` — for gate bias: `softplus(alpha + dt_bias)`
- `ggml_cumsum` — cumulative decay in chunked path
- `ggml_tri` — triangular mask for causal chunked attention
- `ggml_solve_tri` — efficient linear recurrence in chunks
- `ggml_fill` — state initialization

### Existing GGML ops used
- `ggml_exp` — decay: `exp(gate)`
- `ggml_sigmoid` — beta gating: `sigmoid(beta)`
- `ggml_mul_mat` — state @ k, state @ q, etc.
- `ggml_scale` — Q scaling by `1/sqrt(d_k)`
- `ggml_diag` — may be needed for chunked attention

## Phase 3: Rewrite qwen35.cpp (#21)

### Changes needed (from bug list)
1. Replace `ggml_ssm_scan` with `build_delta_net_autoregressive` / `build_delta_net_chunking`
2. Add `ggml_sigmoid(beta)` gating
3. Add Q scaling: `ggml_scale(q, 1/sqrt(S_k))`
4. Fix gate (decay): `gate = softplus(alpha+bias) * ssm_a`, then `exp(gate)`
5. Fix K/Q head repeat: explicit `ggml_repeat_4d`
6. Fix norm+gate order: `rms_norm(y) * silu(z)` before o_proj
7. Fix attention wo: `wo` applied after sigmoid gate, not inside build_attn
8. Fix FFN norm tensor: use correct tensor name
9. Fix Q/gate view: use stride-based `ggml_view_3d` for interleaved Q+gate

### Testing
- `ollama run qwen3.5` with `raw: true` should produce coherent text
- Compare token-by-token with upstream llama.cpp output if possible

## Phase 4: CUDA backends (#19)

### Kernels needed
- `ggml_softplus` — simple element-wise, straightforward
- `ggml_cumsum` — parallel prefix sum (Blelloch or similar)
- `ggml_tri` — simple matrix fill
- `ggml_fill` — simple fill
- `ggml_diag` — already has CPU backend, needs CUDA
- `ggml_solve_tri` — most complex, forward/back substitution

### K80 constraints (cc3.7)
- No tensor cores
- 48KB shared memory
- No cooperative groups
- CUDA 11.4, driver 470

### Priority
Can defer CUDA kernels and test with CPU-only first.
The autoregressive path (single token) is fast enough on CPU for testing.
CUDA needed for practical inference speed.

## Phase 5: Go-side renderer (#15)

The "unknown renderer" error blocks `ollama run qwen3.5` (non-raw mode).
Need to add qwen3.5 chat template support in the Go layer.
This is independent of the C++ work and can be done in parallel.

## Execution order

```
Phase 1 (done) -> Phase 2 -> Phase 3 -> test on CPU -> Phase 4 -> test on GPU
                                                        Phase 5 (parallel)
```

Single PR when Phase 3 produces coherent output.
Phase 4 (CUDA) can be a follow-up PR if needed.
