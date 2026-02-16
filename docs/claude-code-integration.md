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
| 64k (Modelfile) | 15/25 | GPU + CPU | ~47.9 GiB | 10 layers spill to CPU |

## Conclusion: gpt-oss:20b + 64k is Too Large for 4x K80

The 20B model with 64k context exceeds what 4x Tesla K80 (44.8 GiB total VRAM) can handle efficiently — 10/25 layers spill to CPU, severely degrading inference speed. Two approaches to explore:

### Approach 1: Same model, smaller context — gpt-oss:20b with 32k

- Keep the 20B model for quality, halve the context window
- 32k context should roughly halve the compute graph (~16 GiB vs ~33 GiB)
- May allow all 25 layers on GPU (100% GPU offload)
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

### Next Steps

Test both approaches and compare:
1. `ollama ps` — verify GPU layer count and processor split
2. Inference speed — tokens/sec for prompt evaluation and generation
3. Claude Code usability — does 32k context cause issues in practice?

## Launching Claude Code with Ollama

```bash
# Start Ollama server (ensure GPU UVM device files exist first)
sudo nvidia-modprobe -u -c=0
docker compose up -d

# Run Claude Code with Ollama backend
ANTHROPIC_AUTH_TOKEN=ollama \
ANTHROPIC_API_KEY="" \
ANTHROPIC_BASE_URL=http://localhost:11434 \
claude --model gpt-oss:20b-64k
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
