# Plan: Qwen3.5 DeltaNet Rewrite

## Status
- [x] Phase 1: GGML ops (CPU backends) — committed on `issue-18-deltanet-ggml-ops`
- [x] Phase 2: Port delta-net-base graph builder (#20) — merged into Phase 2+3
- [x] Phase 3: Rewrite qwen35.cpp to use DeltaNet builder (#21) — merged into Phase 2+3
- [x] Phase 5: Fix Go-side renderer (#15) — added qwen3.5 renderer/parser
- [ ] Phase 4: CUDA backends for new ops (#19) — IN PROGRESS

All work in PR #22. Model produces coherent output on CPU.
GGML ops hardening in PR #24.

### Phase 4: CUDA backends (#19) — COMPLETE
7 kernels implemented: softplus, cumsum, tri, solve_tri, fill, diag.
3 bugs found and fixed:
1. softplus overflow (missing `x > 20.0f` threshold)
2. solve_tri dimension swap (`n`/`k` from wrong tensor)
3. tri enum mismatch (hardcoded values didn't match `ggml_tri_type` enum order)

Debugging approach: disabled all ops (CPU fallback worked), then binary-searched
by enabling one at a time. tri was the final culprit.

### Additional bugs found during implementation
- Tensor loading mismatch: `attn_post_norm` loaded into `ffn_norm` field
- Tensor loading mismatch: `ssm_dt` bias loaded into `ssm_dt_b` field
- Graph context overflow: `graph_max_nodes` too small (3984 vs ~8200 needed)
  Increased minimum from 1024 to 16384.

### Post-rewrite review findings (PR #24, issue #23)
- GGML ops: added contiguity asserts to `cumsum`/`fill`, `GGML_ASSERT` in `solve_tri`
- Latent chunked path bugs (open, #23):
  - Beta pad on wrong dimension (head vs token) — silent when n_tokens % 64 == 0
  - Gate permute wrong for multi-sequence — silent when n_seqs == 1
  - Original layout works via accidental GGML broadcasting

## Problem (resolved)
The original qwen35.cpp used `ggml_ssm_scan` (Mamba formula) for DeltaNet layers.
This produced garbage output because the formulas are fundamentally different.
See `docs/traces/qwen35-garbage-output.md` for the full 10-bug analysis.

## Approach
Ported upstream llama.cpp PR #19468's approach. They do NOT use `ggml_ssm_scan`.
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

### Testing — PASSED
- `ollama run qwen3.5` produces coherent text (no longer needs `raw: true`)
- Tested: greetings, factual (capital of France), creative (haiku), math (2+2)
- Thinking mode (`<think>` tags) works correctly via renderer/parser

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

## Phase 5: Go-side renderer (#15) — DONE

Added `"qwen3.5"` case to `rendererForName()` and `ParserForName()` in
`model/renderers/renderer.go` and `model/parsers/parsers.go`.
Uses `Qwen3VLRenderer` with thinking support enabled.

## Execution order

```
Phase 1 (done) -> Phase 2+3 (done) -> test on CPU (done) -> Phase 4 (deferred)
                                        Phase 5 (done)
```

PR #22 created. Phase 4 (CUDA backends) deferred to follow-up issue #19.
