---
name: debug
description: Shows environment variables and commands for debugging ollama37. Use when troubleshooting server startup failures, GPU detection issues, CUBLAS errors, or runtime problems.
---

# Debug Skill

## What
Debug and troubleshoot ollama37 runtime issues using environment variables and logging.

## When to use
- Server startup failures
- GPU detection issues
- CUBLAS errors on Tesla K80 or other legacy GPUs
- Verifying compute capability detection
- Troubleshooting batched matrix multiplication issues

## Key environment variables
- `OLLAMA_DEBUG=1` — Verbose Ollama server logging
- `GGML_CUDA_DEBUG=1` — Detailed CUDA/CUBLAS operation logging

## Debugging contexts
- **Native** — Run ollama binary with debug env vars, capture output to log files
- **Docker** — Pass debug env vars via `-e` flags, inspect container libraries and logs
