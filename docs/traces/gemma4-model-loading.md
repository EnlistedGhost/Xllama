# Trace: gemma4 Model Loading and Inference Path

**Issue**: #59 — gemma4:26b fails to load model blob
**Date**: 2026-04-10
**Error**: `unable to load model: /root/.ollama/models/blobs/sha256-...`

## Root Cause

`gemma4` is missing from `OllamaEngineRequired()` in `fs/ggml/ggml.go:242-253`.
Without this, the engine selection at `llm/server.go:152` skips the new Ollama engine
and falls through to the old llama.cpp runner (`llama.LoadModelFromFile`), which does
not understand gemma4 architecture — returning nil and producing the error at
`llama/llama.go:380`.

## Call Flow: CLI → Engine Selection → Error

```
cmd.RunHandler()                                    # cmd/cmd.go:333
  └── api.Client.Generate()                         # api/client.go:266
        POST /api/generate
          └── Server.GenerateHandler()              # server/routes.go:193
                └── s.scheduleRunner()              # server/routes.go:407
                      └── Scheduler.load()          # server/sched.go:401
                            └── NewLlamaServer()    # llm/server.go:148
```

### Engine Selection (llm/server.go:148-168)

```go
func NewLlamaServer(..., f *ggml.GGML, ...) {
    var textProcessor model.TextProcessor

    if envconfig.NewEngine() || f.KV().OllamaEngineRequired() {   // :152
        // NEW ENGINE PATH — requires "gemma4" in the list
        textProcessor, err = model.NewTextProcessor(modelPath)     // :154
    }

    if textProcessor == nil {                                      // :163
        // OLD ENGINE PATH (fallback) — llama.cpp, fails for gemma4
        llamaModel, err = llama.LoadModelFromFile(modelPath, ...)  // :164
        //  → llama_model_load_from_file() returns nil              # llama/llama.go:376
        //  → fmt.Errorf("unable to load model: %s", modelPath)    # llama/llama.go:380
    }
}
```

### OllamaEngineRequired (fs/ggml/ggml.go:241-254)

```go
func (kv KV) OllamaEngineRequired() bool {
    return slices.Contains([]string{
        "gemma3", "gemma3n",        // ✓ present
        "gptoss", "gpt-oss",
        "llama4", "mistral3", "mllama",
        "qwen25vl", "qwen3", "qwen3moe",
        "qwen3vl", "qwen3vlmoe", "qwen35",
        // "gemma4"                 // ✗ MISSING — this is the bug
    }, kv.Architecture())
}
```

**Fix**: Add `"gemma4"` to the list. The GGUF file (from Ollama registry) already has
`general.architecture = "gemma4"` in its KV metadata.

## Call Flow: New Engine Path (after fix)

Once `OllamaEngineRequired()` returns `true` for gemma4, the new engine path activates:

```
NewLlamaServer()                                    # llm/server.go:148
  └── model.NewTextProcessor(modelPath)             # model/model.go:122
        ├── fsggml.Decode(file)                     # fs/ggml/ggml.go:516
        │     ├── Read GGUF magic/version           # fs/ggml/gguf.go:47
        │     ├── Read KV metadata → KV map         # fs/ggml/gguf.go:142
        │     └── Read tensor metadata              # fs/ggml/gguf.go:194
        └── modelForArch(meta.KV())                 # model/model.go:134→93
              ├── arch = "gemma4"                    # KV["general.architecture"]
              ├── models["gemma4"] → gemma4.New      # registered at gemma4/model.go:263
              └── gemma4.New(c)                      # gemma4/model.go:54
                    ├── Build vocabulary             # :55-69
                    ├── newTextModel(c)              # model_text.go:83
                    ├── newVisionModel(c)            # model_vision.go
                    ├── newAudioModel(c)             # model_audio.go
                    └── Setup KV cache               # :113-117
                          NewWrapperCache(
                            SWAMemCache(window, 4096, Shift),   # SWA layers
                            CausalCache(Shift)                  # Global layers
                          )
```

### Runner Subprocess

After NewTextProcessor succeeds, the runner subprocess is spawned:

```
StartRunner(ollamaEngine=true, modelPath, port)     # llm/server.go:327
  └── exec.Command("ollama", "runner",
        "--ollama-engine", "--model", path,
        "--port", port)                              # :376
```

## Call Flow: Model Loading in Runner

The runner subprocess loads the full model (tensors + weights):

```
model.New(modelPath, params)                         # model/model.go:105
  ├── ml.NewBackend(modelPath, params)               # ml/backend.go:90
  │     └── ggml.New(modelPath, params)              # ml/backend/ggml/ggml.go:123
  │           ├── fsggml.Decode(file)                # :124 — parse GGUF
  │           ├── initDevices()                      # :147 — enumerate GPU/CPU
  │           ├── assignLayer()                      # :203 — distribute layers to devices
  │           ├── createTensor() loop                # :230 — allocate tensor structs
  │           └── Load()                             # :468 — read weights from file
  │                 ├── SectionReader per tensor      # :521
  │                 ├── Type conversion (BF16→F32)    # :568
  │                 └── ggml_backend_tensor_set()     # :614 — copy to GPU/CPU
  ├── modelForArch(b.Config())                       # model/model.go:107→93
  │     └── gemma4.New(c)                            # (same factory as above)
  └── populateFields(base, model)                    # model/model.go:112→160
        └── For each `gguf:"name"` tagged field:
              Backend.Get("name") → ml.Tensor        # ml/backend/ggml/ggml.go:656
```

### GGUF Tag to Tensor Mapping (gemma4 examples)

| Go struct field | GGUF tag | GGUF tensor name |
|---|---|---|
| `TextModel.TokenEmbedding` | `gguf:"token_embd"` | `token_embd.weight` |
| `TextModel.Layers[i].SelfAttention.Query` | `gguf:"attn_q"` | `blk.{i}.attn_q.weight` |
| `VisionModel` | `gguf:"v"` | `v.*` prefix |
| `AudioModel` | `gguf:"a"` | `a.*` prefix |
| `MultiModalProjector` | `gguf:"mm"` | `mm.*` prefix |

## Call Flow: Inference (Forward Pass)

```
HTTP POST /completion
  └── Server.completion()                            # runner/ollamarunner/runner.go:805
        └── s.NewSequence()                          # :847
              ├── TextProcessor.Encode(text)          # :219 — tokenize
              ├── EncodeMultimodal(ctx, imageBytes)   # :240 (if multimodal)
              │     ├── isAudioData()? → encodeAudioMultimodal()
              │     └── VisionModel.Forward()         # gemma4/model.go:153
              │           visionPoolAndProject()      # :154
              └── PostTokenize(inputs)                # :264 (if multimodal)
                    └── Insert <|image>/<image|> tokens  # gemma4/model.go:202

Background: server.run()                             # :1389
  └── forwardBatch() loop                            # :412
        ├── Build input.Batch                        # :475-609
        │     Inputs (token IDs), Positions, Outputs, Multimodal
        └── model.Forward(ctx, batch)                # :602
              └── gemma4.Model.Forward()              # gemma4/model.go:243
                    ├── TextModel.Forward(ctx, batch, cache)  # model_text.go:167
                    │     ├── TokenEmbedding.Forward() * sqrt(hiddenSize)
                    │     ├── Inject vision embeddings via Copy()
                    │     ├── PerLayerProjector.Forward() (PLE)
                    │     └── for each layer i:
                    │           ├── cache.SetLayer(i)
                    │           ├── WrapperCache.SetLayerType(SWA|Causal)
                    │           ├── kvDonorMap[i]? → cache.SetLayer(donor) (KV sharing)
                    │           └── TextLayer.Forward()        # model_text.go:416
                    │                 ├── AttentionNorm → SelfAttention → PostAttentionNorm
                    │                 │     ├── Q/K/V projections
                    │                 │     ├── Q/K norms, V unweighted RMSNorm
                    │                 │     ├── nn.RoPE (NeoX + freq_factors for global)
                    │                 │     └── nn.Attention(q, k, v, cache)
                    │                 ├── if MoE: MLP ∥ MoE, sum
                    │                 │     ├── MLP: Gate.GELU(Up) → Down
                    │                 │     └── MoE: Router → expert select → Down
                    │                 │           PostMLPNorm1 + PostMoENorm → PostMLPNorm
                    │                 ├── else: MLPNorm → MLP → PostMLPNorm
                    │                 ├── PLE injection (gate, project, norm)
                    │                 └── LayerScalar (global layers only)
                    │     └── OutputNorm.Forward()
                    ├── Output.Forward() (logit projection)
                    └── finalLogitSoftcap: Scale → Tanh → Scale

Sampling:                                            # runner/ollamarunner/runner.go:702
  ├── outputs = modelOutput.Floats()                 # :702
  ├── sampler.Sample(logits)                         # :732
  │     ├── Top-K                                    # sample/samplers.go:92
  │     ├── Temperature                              # :95
  │     ├── Softmax                                  # :96
  │     ├── Top-P                                    # :98
  │     └── Min-P                                    # :99
  └── TextProcessor.Decode(token) → text             # runner.go:770+
```

## KV Cache Architecture (gemma4-specific)

gemma4 uses `WrapperCache` with two sub-caches:

```
WrapperCache                              # kvcache/wrapper.go:12
  ├── [0] SWAMemCache(window, 4096)       # Sliding Window Attention layers
  │         swaWindowSize = slidingWindowLen
  │         swaMemorySize = 4096
  └── [1] CausalCache                     # Global (full) attention layers

Per-layer routing (model_text.go:192-199):
  isLocal(layer) → cacheTypeSWA (index 0)
  !isLocal(layer) → cacheTypeCausal (index 1)

KV sharing (model_text.go:217-222):
  Layers >= firstShared reuse K/V from donor layer
  kvDonorMap[sharedLayer] = lastNonSharedLayerOfSameType
```

## gemma4 Architecture Features

| Feature | Location | Description |
|---|---|---|
| Sliding Window Attention | `slidingWindowPattern` from config `attention.sliding_window_pattern` | Per-layer bool array |
| Global vs Local head dims | `headDim` (SWA=256), `globalHeadDim` (full=512) | Different K/Q/V sizes per layer type |
| Proportional RoPE | `RopeFactors` tensor `rope_freqs.weight` | freq_factors on global layers only |
| KV Sharing | `kvDonorMap` from `attention.shared_kv_layers` | Tail layers reuse earlier K/V |
| MoE (sparse) | `TextRouter` + `TextMoEBlock` | Parallel MLP + MoE, summed |
| Per-Layer Embedding (PLE) | `PerLayerProjector` | Extra input per layer |
| V-norm | `v.RMSNorm(ctx, nil, eps)` | Unweighted RMSNorm on values |
| Final logit softcap | `Scale → Tanh → Scale` | Caps logit magnitude |
| Vision | SigLIP encoder + pool + project | `model_vision.go` |
| Audio | Mel spectrogram + AST encoder | `model_audio.go` |
| Multimodal | `<|image>`, `<image|>`, `<|audio>`, `<audio|>` tokens | PostTokenize injects tokens |
