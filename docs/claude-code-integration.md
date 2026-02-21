# Claude Code + Ollama Integration

## Overview

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) is Anthropic's official CLI tool for working with Claude. It can use Ollama as a backend via the OpenAI-compatible API, enabling local LLM inference.

This document covers running Claude Code with Ollama on a 4x Tesla K80 GPU setup, including context length configuration, memory analysis, and launch instructions.

## Prerequisites

- Ollama server running (via Docker or native)
- NVIDIA GPU(s) with working drivers
- GPU UVM device files must exist before starting Ollama:

```bash
sudo nvidia-modprobe -u -c=0
```

## Context Length Configuration

### Background

Claude Code requires a **large context window** — at least 64k tokens recommended.

Ollama auto-assigns context based on available VRAM:
- < 24 GiB VRAM: **4k context** (default)
- 24-48 GiB VRAM: **32k context**
- \>= 48 GiB VRAM: **256k context**

**Problem**: Even with 4x Tesla K80 GPUs (44.8 GiB total VRAM), Ollama defaults to 4k context because it evaluates per-GPU VRAM (11.2 GiB), not total.

### Setting Context via Modelfile

Create a model variant with baked-in context length:

```bash
# Inside the container
echo 'FROM gpt-oss:20b
PARAMETER num_ctx 65536' > /tmp/Modelfile

ollama create gpt-oss:20b-64k -f /tmp/Modelfile
```

This persists the context setting into the model — no environment variable needed.

## Memory Analysis: gpt-oss:20b with 64k Context on 4x Tesla K80

**Test date**: 2026-02-16

**Configuration**: gpt-oss:20b-64k (native MXFP4 quantization at 4.25 bits/param, 20.9B parameters, 64k context)

> **Note**: MXFP4 is the model's native training precision (quantization-aware trained), not a
> post-training compression like Q4_K_M. This is already the highest quality available — further
> quantization would degrade quality.

**Layer distribution**: 15/25 layers on GPU (60%), 10/25 layers + output on CPU (40%)

| Device | Weights | KV Cache | Compute Graph | Total | Capacity |
|--------|---------|----------|---------------|-------|----------|
| CUDA0 (K80) | 1.3 GiB | 265 MiB | 8.7 GiB | 10.3 GiB | 11.2 GiB |
| CUDA1 (K80) | 1.8 GiB | 274 MiB | 8.2 GiB | 10.3 GiB | 11.2 GiB |
| CUDA2 (K80) | 1.8 GiB | 274 MiB | 8.2 GiB | 10.3 GiB | 11.2 GiB |
| CUDA3 (K80) | 1.8 GiB | 274 MiB | 8.2 GiB | 10.3 GiB | 11.2 GiB |
| CPU | 6.2 GiB | 557 MiB | 16 MiB | 6.8 GiB | 15.4 GiB |
| **Total** | **12.9 GiB** | **1.6 GiB** | **33.3 GiB** | **47.9 GiB** | |

**Key findings**:
- The **compute graph** is the bottleneck (~8.2-8.7 GiB per GPU), not model weights or KV cache
- Compute graph scales with context length — 64k context requires ~33.3 GiB across GPUs
- GPUs are nearly full (~10.3/11.2 GiB = 92% utilization)
- 10 layers + KV cache spill to CPU, causing slower inference due to CPU-GPU data transfer

## Context Length vs GPU Offload Comparison

| Context | GPU Layers | Processor | Total Memory | Notes |
|---------|------------|-----------|--------------|-------|
| 4k (default) | 25/25 | 100% GPU | ~16 GiB | Full GPU offload |
| 32k (Modelfile) | 25/25 | 100% GPU | ~23 GiB | Full GPU offload |
| 64k (Modelfile) | 15/25 | GPU + CPU | ~47.9 GiB | 10 layers spill to CPU |

## Conclusion: gpt-oss:20b + 64k is Too Large for 4x K80

The 20B model with 64k context exceeds what 4x Tesla K80 (44.8 GiB total VRAM) can handle efficiently — 10/25 layers spill to CPU, severely degrading inference speed. Two approaches to explore:

### Approach 1: Same model, smaller context — gpt-oss:20b with 32k (Tested)

- Keep the 20B model for quality, halve the context window
- **Result: 100% GPU offload, 25/25 layers on GPU, 23 GB total**
- Compute graph halved (~16 GiB vs ~33 GiB) — the dominant memory consumer at 64k
- No CPU spill eliminates the CPU-GPU transfer overhead
- Trade-off: Claude Code works better with larger context, 32k may be tight for complex tasks

```bash
echo 'FROM gpt-oss:20b
PARAMETER num_ctx 32768' > /tmp/Modelfile
ollama create gpt-oss:20b-32k -f /tmp/Modelfile
```

### Approach 2: Smaller model, full context — 10-12B model with 64k

- Use a smaller model that fits in VRAM with 64k context
- Smaller weights + smaller compute graph = more room for KV cache
- Trade-off: reduced model quality, but full context window for Claude Code

Candidate models to test:
- `gpt-oss:12b` (if available)
- `qwen3-coder:14b`
- `glm-4.7:9b`

### Why 32k vs 64k Is Such a Big Difference

The **compute graph** dominates memory at large context lengths (70% of total at 64k). It scales linearly with context, so halving context roughly halves the biggest memory consumer. At 64k the compute graph alone (~33 GiB) exceeds total GPU VRAM (44.8 GiB), forcing layer spill to CPU. At 32k (~16 GiB), everything fits comfortably.

### Next Steps

1. Test Claude Code usability with 32k context — does it cause issues in practice?
2. Test approach 2 (smaller model + 64k) if 32k proves too limiting
3. Compare inference speed between configurations

## Test Results

**Date**: 2026-02-16

**Setup**: Claude Code CLI -> Ollama (`/v1/messages` Anthropic API) -> gpt-oss:20b-32k on 4x Tesla K80

```
❯ hi

● Hello! How can I help you today?

✻ Sautéed for 3m 53s

❯ /model
  ⎿  Kept model as gpt-oss:20b-32k
```

**Status**: Working end-to-end. Claude Code successfully communicates with Ollama via the Anthropic Messages API (`/v1/messages`). Response time is ~4 minutes for a simple greeting due to K80 inference speed.

### Test 2: qwen3:4b-32k — Small Model Fails Under Claude Code

**Date**: 2026-02-16

**Setup**: Claude Code CLI (Docker) -> Ollama (`/v1/messages` Anthropic API) -> qwen3:4b-32k on 4x Tesla K80

**Direct Ollama query** (no Claude Code): ~15-25 seconds per response — fast and functional.

**Via Claude Code**: Timed out after 3 minutes with no response. Ollama logs show the `/v1/messages` request took **4m17s** before being killed.

```
[GIN] 2026/02/16 - 13:03:38 | 200 |         4m17s |      172.22.0.3 | POST     "/v1/messages?beta=true"
```

**GPU stats during test**: Max temperature 78°C (under 83°C safety limit), model fully loaded in VRAM (9.99 GiB).

**Root cause**: Claude Code sends a very large system prompt with every request via `/v1/messages`. The prompt processing (prefill) step is compute-bound, and on K80 hardware (no Tensor Cores, GDDR5 memory bandwidth) this dominates total response time. A 5x smaller model (4B vs 20B) showed no improvement — both took ~4 minutes because the bottleneck is system prompt prefill, not model size.

### Test 3: gemma3:4b-32k — Rejected (No Tool Support)

**Date**: 2026-02-16

**Setup**: Claude Code CLI (Docker) -> Ollama (`/v1/messages` Anthropic API) -> gemma3:4b-32k on 4x Tesla K80

**Direct Ollama query** (no Claude Code): ~1.6 seconds warm, 90ms prompt eval — very fast.

**Via Claude Code**: Immediately rejected with API error:

```
API Error: 400 {"type":"error","error":{"type":"invalid_request_error",
"message":"registry.ollama.ai/library/gemma3:4b-32k does not support tools"}}
```

**Root cause**: Claude Code requires tool-calling support (for file operations, bash execution, etc.). gemma3:4b does not have tool-calling in its model template. This is a compatibility issue, not a performance issue — the model is fast but fundamentally incompatible with Claude Code.

**Note**: Only models with tool-calling support work with Claude Code. The [Ollama blog](https://ollama.com/blog/claude-code) recommends: qwen3-coder, glm-4.7, gpt-oss.

### Test 4: llama3.2:3b-32k — Working (With Bug Fix)

**Date**: 2026-02-16

**Setup**: Claude Code CLI (Docker) -> Ollama (`/v1/messages` Anthropic API) -> llama3.2:3b-32k on 4x Tesla K80

**Direct Ollama query** (no Claude Code): ~1.1 seconds warm, 53ms prompt eval.

**Via Claude Code (first attempt)**: Failed with `tool_use block missing required 'id' field`. Ollama's tool parsers don't generate tool call IDs, and the Anthropic `/v1/messages` layer was passing empty IDs through. Fixed by generating `toolu_XXXX` IDs in `anthropic/anthropic.go`, mirroring what the OpenAI layer already does with `call_XXXX`.

**Via Claude Code (after fix, model pre-loaded)**:

```
[GIN] 2026/02/16 - 14:54:47 | 200 |         2m16s | POST     "/v1/messages?beta=true"
[GIN] 2026/02/16 - 14:55:05 | 200 |  18.61122293s | POST     "/v1/messages?beta=true"
```

- First request (system prompt prefill): **2m16s**
- Second request (actual query): **18.6s**
- Both returned **200** — tool_use ID fix confirmed working

**Note**: llama3.2:3b is a small model (3.2B params) that responds well through Claude Code once the system prompt is cached. The ~2 min initial prefill is a one-time cost per conversation. Subsequent requests take ~19s which is usable for simple tasks.

### Conclusion: Tesla K80 Claude Code Compatibility

| Model | Params | Tool Support | Direct Ollama | Via Claude Code | Result |
|-------|--------|-------------|---------------|-----------------|--------|
| gpt-oss:20b-32k | 20.9B | Yes | ~30-60s | ~4 min | Working but very slow |
| qwen3:4b-32k | 4B | Yes | ~15-25s | >3 min (timeout) | Failed |
| gemma3:4b-32k | 4.3B | **No** | ~1.6s | Rejected | Incompatible |
| llama3.2:3b-32k | 3.2B | Yes | ~1.1s | 2m16s + 19s/req | Working |

**Key findings**:
1. **Performance**: The bottleneck is Claude Code's large system prompt prefill. On K80 GPUs (no Tensor Cores, GDDR5), this takes ~2 min even for a 3B model. Subsequent requests are faster (~19s) once the system prompt is processed.
2. **Compatibility**: Not all models work with Claude Code — tool-calling support is required. gemma3 lacks this. llama3.2 has tool support but needed a bug fix for missing tool_use IDs in the Anthropic API layer.
3. **Bug fix**: Ollama's tool parsers don't generate tool call IDs. The OpenAI compatibility layer already worked around this (`call_XXXX`), but the Anthropic layer did not. Fixed by generating `toolu_XXXX` IDs in both streaming and non-streaming response paths.

**Recommendation**: llama3.2:3b-32k is the best option for Claude Code on K80 — small enough for fast inference, has tool support, and works after the ID fix. Expect ~2 min for the first response (system prompt prefill) and ~19s for subsequent responses.

## Launching Claude Code with Ollama

```bash
# Start Ollama server (ensure GPU UVM device files exist first)
sudo nvidia-modprobe -u -c=0
docker compose up -d

# Run Claude Code with Ollama backend
ANTHROPIC_AUTH_TOKEN=ollama \
ANTHROPIC_API_KEY="" \
ANTHROPIC_BASE_URL=http://localhost:11434 \
claude --model gpt-oss:20b-32k
```

## Diagnostic Commands

```bash
# Check what context a running model actually has
ollama ps

# Output shows CONTEXT column with actual allocated tokens
# NAME              ID           SIZE     PROCESSOR    CONTEXT    UNTIL
# gpt-oss:20b      17052f91a42e 16 GB    100% GPU     8192       4 minutes from now

# Show model max context capability (not runtime allocation)
ollama show gpt-oss:20b

# Check Docker container logs
docker compose logs -f
```

## Recommended Models for Claude Code

From [Ollama docs](https://ollama.com/blog/claude-code):
- qwen3-coder
- glm-4.7
- gpt-oss:20b
- gpt-oss:120b
