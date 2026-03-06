# Trace: qwen35 ggml_reshape_3d assertion failure

## Symptom
```
GGML_ASSERT(ggml_nelements(a) == ne0*ne1*ne2) failed
```
Occurs on first inference with `qwen3.5:9b`. The llama runner process terminates.

## Model hparams
```
n_embd = 4096, n_head = 16, n_embd_head = 256
n_head_kv = [0,0,0,4, 0,0,0,4, ...] (per-layer; 0 = recurrent, 4 = attention)
d_conv = 4, d_inner = 4096, d_state = 128
n_head_ssm = 32, n_group = 16
full_attention_interval = 4
```

## Call flow
```
llm_build_qwen35::llm_build_qwen35()          # llama-model.cpp:12108
  llm_graph_context::n_head_kv                 # initialized from hparams.n_head_kv(0) = 0
  for il = 0..31:
    if hparams.is_recurrent(il):               # layers 0,1,2, 4,5,6, 8,9,10, ...
      [DeltaNet path — does NOT use n_head_kv, OK]
    else:                                      # layers 3,7,11,15,...
      q_dim = n_embd_head * n_head             # 256 * 16 = 4096
      Qcur = ggml_reshape_3d(Qcur, 256, 16, n_tokens)   # OK: 4096 == 256*16*1
      Kcur = ggml_reshape_3d(Kcur, 256, n_head_kv, n_tokens)  # <-- FAILS
        n_head_kv = 0 (from context, layer 0)
        Kcur has 1024 elements (from wk @ 256*4)
        target = 256 * 0 * 1 = 0
        ASSERT: 1024 != 0  =>  CRASH
```

## Root cause
`n_head_kv` in `llm_graph_context` is initialized from `hparams.n_head_kv(0)` which returns
the value for layer 0 (a recurrent layer with n_head_kv=0). The attention branch at line 12313
uses this context-level variable instead of the per-layer value.

## Fix
Add per-layer `n_head_kv` inside the loop, matching the Jamba pattern:

```cpp
// Inside the for loop, at the start:
const int64_t n_head_kv = hparams.n_head_kv(il);
```

This shadows the context-level `n_head_kv` with the correct per-layer value (4 for attention layers).

## Reference
- Jamba does this at llama-model.cpp:6990
- Bailing does this at llama-model.cpp:12411
- DiffuserGPT does this at llama-model.cpp:13347

## Verified
- [x] Assertion source: ml/backend/ggml/ggml/src/ggml.c:3439
- [x] hparams confirmed from docker logs
- [x] n_head_kv(0) = 0 confirmed from per-layer array
- [ ] Fix not yet applied — needs build + test
