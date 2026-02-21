---
name: debug
description: Shows environment variables and commands for debugging ollama37. Use when troubleshooting server startup failures, GPU detection issues, CUBLAS errors, or runtime problems.
---

# Debug and Logging Options

## Environment Variables
- `OLLAMA_DEBUG=1` - Enable verbose Ollama server logging
- `GGML_CUDA_DEBUG=1` - Enable detailed CUDA/CUBLAS operation logging (batched matrix multiplication)

## Running with Debug Logging

```bash
# Ollama verbose logging only
OLLAMA_DEBUG=1 ./ollama serve

# Both Ollama and CUDA debug logging
OLLAMA_DEBUG=1 GGML_CUDA_DEBUG=1 ./ollama serve

# Capture all output to file
./ollama serve 2>&1 | tee /tmp/ollama_serve.log

# Capture only stderr (warnings/errors) to file
./ollama serve 2> /tmp/ollama_errors.log

# Run in background with full logging
OLLAMA_DEBUG=1 ./ollama serve 2>&1 | tee /tmp/ollama_full.log &

# Run in background with debug logging
OLLAMA_DEBUG=1 GGML_CUDA_DEBUG=1 ./ollama serve 2>&1 | tee /tmp/ollama_debug.log &

# Monitor a running background server
tail -f /tmp/ollama_full.log

# Tail recent log entries
tail -100 /tmp/ollama_full.log

# Stop all ollama processes
pkill ollama
```

## Docker Container Debugging

```bash
# Run with debug logging in Docker
docker run --rm --runtime=nvidia --gpus all \
  -e OLLAMA_DEBUG=1 \
  -e GGML_CUDA_DEBUG=1 \
  -p 11434:11434 \
  ollama37:latest

# Check library paths in container
docker exec ollama37 bash -c 'echo $LD_LIBRARY_PATH'

# List GGML/CUDA libraries
docker exec ollama37 ls /usr/lib/ollama/

# Check Docker compose logs
docker compose logs -f
```

## When to Use GGML_CUDA_DEBUG
- Debugging CUBLAS errors on Tesla K80 or other legacy GPUs
- Verifying compute capability detection
- Troubleshooting batched matrix multiplication issues
- Understanding which CUBLAS functions are being used (legacy vs Ex variants)
