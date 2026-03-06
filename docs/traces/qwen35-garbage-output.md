# Trace: qwen35 garbage output - DeltaNet scan formula mismatch

## Symptom
Model loads and generates tokens (no crash), but output is incoherent garbage:
mixed languages, random tokens, fim markers appearing in regular text.

## Model architecture
- 32 layers: 24 recurrent (DeltaNet), 8 full attention (every 4th layer)
- n_embd=4096, n_head=16, n_embd_head=256
- DeltaNet: d_inner=4096, d_state=128, n_head_ssm=32, n_group=16, head_dim=128

## Root cause: ggml_ssm_scan formula mismatch

### What ggml_ssm_scan computes (Mamba/Mamba2 formula)
```
dt_sp = softplus(dt)                              // ops.cpp:8676
dA = exp(dt_sp * A)                               // ops.cpp:8677
x_dt = x * dt_sp                                  // ops.cpp:8683
state = state * dA + B * x_dt                      // ops.cpp:8684+
y = C * state
```
Expanded: `state_t = exp(softplus(dt) * A) * state_{t-1} + B * x * softplus(dt)`

### What DeltaNet needs
```
decay = sigmoid(alpha)           // or some gating function
state_t = decay * state_{t-1} + K^T * V_gated
y_t = Q * state_t
```
Key differences:
1. **Decay**: DeltaNet uses sigmoid gate, not exp(softplus(dt)*A)
2. **x scaling**: ggml_ssm_scan multiplies x by softplus(dt), DeltaNet does NOT scale V by alpha

### Parameter mapping in our code (llama-model.cpp:12244-12256)
```
ggml_ssm_scan(ctx, ssm, V, alpha, A, K, Q, ids)
                    ^    ^     ^    ^  ^  ^
                    s    x    dt    A  B  C
```
- V (as x) gets scaled by softplus(alpha) inside the kernel -- WRONG for DeltaNet
- alpha (as dt) produces exp(softplus(alpha)*A) decay -- WRONG for DeltaNet

### Mathematical analysis
If A = -1 (typical for DeltaNet in GGUF), then:
- `exp(softplus(dt) * (-1))` = `sigmoid(-dt)` = `1 - sigmoid(dt)`
- To get `sigmoid(alpha)` as decay, pass `-alpha` as dt
- But V scaling by `softplus(-alpha)` is still unwanted

### Potential fix approaches
1. **New GGML op**: Implement `ggml_deltanet_scan` with the correct formula
   - Most correct, but requires changes to ggml-cpu/ops.cpp, ggml-cuda/ssm-scan.cu, etc.
2. **Pre-transform inputs**: Compensate for softplus in the graph builder
   - Pass `-alpha` as dt to get sigmoid(alpha) decay (when A=-1)
   - Pre-divide V by softplus(-alpha) to undo the x scaling
   - Fragile, numerically unstable near softplus(x)~0
3. **Check upstream**: The upstream llama.cpp PR #19468 may have already solved this
   - Either by adding a new op or by using a different graph construction

## Call flow
```
llm_build_qwen35::llm_build_qwen35()              # llama-model.cpp:12108
  for il in recurrent layers:
    alpha = mm(ssm_alpha, cur) + ssm_dt_b          # {32, n_seq_tokens, n_seqs}
    beta  = mm(ssm_beta, cur)                       # {32, n_seq_tokens, n_seqs}
    qkv   = mm(wqkv, cur) -> conv1d -> silu         # {8192, n_seq_tokens, n_seqs}
    Q,K,V = split(qkv)                              # Q,K={128,16,...} V={128,32,...}
    V     = V * beta                                 # beta gating on V
    Q,K   = l2_norm(Q), l2_norm(K)
    alpha = reshape_3d(alpha, 32, ...)
    A     = reshape_2d(ssm_a, 1, 32)                # {1, 32}
    ggml_ssm_scan(ssm, V, alpha, A, K, Q, ids)      # WRONG FORMULA
      kernel: state = exp(sp(alpha)*A) * state + K * V * sp(alpha)
      wanted: state = sigmoid(alpha) * state + K * V
```

## Verified
- [x] ggml_ssm_scan always applies softplus to dt (cpu: ops.cpp:8676, cuda: ssm-scan.cu:86)
- [x] ggml_ssm_scan always scales x by softplus(dt) (cpu: ops.cpp:8683, cuda: ssm-scan.cu:88)
- [x] No DeltaNet-specific scan op exists in the codebase
- [x] Mamba2 reference (build_mamba2_layer) uses same scan but with Mamba2-trained weights
- [ ] A tensor values not yet inspected (need to dump from GGUF)
- [ ] Upstream PR #19468 approach not yet verified

## Upstream comparison (llama.cpp PR #19468, merged)

Upstream completely rewrites the DeltaNet path. Key file: `src/models/delta-net-base.cpp`

### Critical finding: upstream does NOT use ggml_ssm_scan

Upstream implements DeltaNet with explicit matrix ops (`ggml_mul`, `ggml_exp`,
`ggml_mul_mat`, etc.) via two paths:
- `build_delta_net_autoregressive()` — single token (inference)
- `build_delta_net_chunking()` — multi-token (prompt processing)

### Bug list (our code vs upstream)

| # | Bug | Our code | Upstream |
|---|-----|----------|----------|
| 1 | **SSM scan** | Uses `ggml_ssm_scan` (Mamba formula) | Custom DeltaNet ops (no ssm_scan) |
| 2 | **Beta gate** | Raw linear projection | `ggml_sigmoid(beta)` |
| 3 | **Q scaling** | No scaling | `q = ggml_scale(q, 1/sqrt(S_k))` |
| 4 | **Gate (decay)** | alpha passed directly to ssm_scan dt | `gate = softplus(alpha+bias) * ssm_a`, then `exp(gate)` for decay |
| 5 | **K/Q head repeat** | GQA via ssm_scan broadcast (16 groups, 32 heads) | Explicit `ggml_repeat_4d` to match num_v_heads |
| 6 | **Norm + gate order** | `o_proj(rms_norm(y))` then `* silu(z)` | `rms_norm(y) * silu(z)` (gate before o_proj) |
| 7 | **Attention wo** | `wo` inside `build_attn` | `wo` applied after sigmoid gate |
| 8 | **FFN norm** | Uses `ffn_norm` tensor | Uses `attn_post_norm` tensor |
| 9 | **Q/gate view** | `ggml_cont(ggml_view_2d(...))` flat then reshape | `ggml_view_3d` with stride=2*head_dim (interleaved) |
| 10 | **Conv channels** | `key_dim*2 + value_dim` = 8192 | `d_inner + 2*n_group*d_state` = 8192 (same value, different formula) |

### Upstream autoregressive DeltaNet formula
```python
# gate = exp(softplus(alpha + bias) * ssm_a)  # decay, ssm_a < 0
# state = state * gate
# d = (v - state^T @ k) * sigmoid(beta)       # delta rule
# state = state + k * d^T                      # rank-1 update
# output = state^T @ q * scale                 # readout
```

### Upstream attention layer differences
- Q projection output is `n_embd_head * 2 * n_head` (Q + gate interleaved per head)
- Q is extracted via stride-based `ggml_view_3d` (stride = 2 * n_embd_head), NOT flat view_2d
- Q norm applied to strided view, THEN gate extracted similarly
- `build_attn` called with `wo=nullptr, bo=nullptr` (no output projection inside)
- Sigmoid gate applied to attention output
- `wo` applied AFTER gating as separate `build_lora_mm`

## Recommendation
The DeltaNet implementation needs a substantial rewrite to match upstream.
This is NOT a minor fix — it requires replacing `ggml_ssm_scan` with custom
DeltaNet ops and fixing at least 9 other bugs. Consider porting the upstream
`delta-net-base.cpp` and `qwen35.cpp` directly.
