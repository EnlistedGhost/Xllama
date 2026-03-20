Help the user debug ollama37. Reference `.claude/skills/debug/SKILL.md` for context.

Show the relevant commands based on the user's issue.

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
