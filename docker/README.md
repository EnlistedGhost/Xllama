# Ollama37 Docker Build System

**Single-stage Docker build for Ollama with CUDA 11.4 and Compute Capability 3.7 support (Tesla K80)**

## Overview

This Docker build system creates a single all-in-one image that includes:
- CUDA 11.4 toolkit (required for Tesla K80, compute capability 3.7)
- GCC 10 (built from source, required by CUDA 11.4)
- CMake 4.0 (built from source)
- Go 1.25.3
- Ollama37 binary with K80 GPU support

The image is built entirely from source by cloning from https://github.com/dogkeeper886/ollama37

## Prerequisites

- Docker with NVIDIA Container Runtime
- NVIDIA GPU drivers (470+ for Tesla K80)
- Verify GPU access:
  ```bash
  docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.4.3-base-rockylinux8 nvidia-smi
  ```

## Quick Start

### 1. Build the Image

```bash
cd /home/jack/Documents/ollama37/docker
docker build -t ollama37:latest -f Dockerfile ..
```

**Build time:** ~90 minutes (first time, includes building GCC 10 and CMake 4 from source)

**Image size:** ~20GB (includes full build toolchain + CUDA toolkit + Ollama)

### 2. Run with Docker Compose (Recommended)

```bash
docker-compose up -d
```

Check logs:
```bash
docker-compose logs -f
```

### 3. Run Manually

```bash
docker run -d \
  --name ollama37 \
  --runtime=nvidia \
  --gpus all \
  -p 11434:11434 \
  -v ollama-data:/root/.ollama \
  ollama37:latest
```

## Usage

### Using the API

```bash
# List models
curl http://localhost:11434/api/tags

# Pull a model
curl http://localhost:11434/api/pull -d '{"name": "gemma3:4b"}'

# Run inference
curl http://localhost:11434/api/generate -d '{
  "model": "gemma3:4b",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

### Using the CLI

```bash
# List models
docker exec ollama37 ollama list

# Pull a model
docker exec ollama37 ollama pull gemma3:4b

# Run a model
docker exec ollama37 ollama run gemma3:4b "Hello!"
```

## Architecture

### Single-Stage Build Process

The Dockerfile performs these steps in order:

1. **Base Setup** (10 min)
   - Rocky Linux 8
   - CUDA 11.4 toolkit installation
   - Development tools

2. **Build Toolchain** (70 min)
   - GCC 10 from source (~60 min)
   - CMake 4 from source (~8 min)
   - Go 1.25.3 binary (~1 min)

3. **Ollama Compilation** (10 min)
   - Git clone from dogkeeper886/ollama37
   - CMake configure with "CUDA 11" preset
   - Build C/C++/CUDA libraries
   - Build Go binary

4. **Runtime Setup**
   - Configure library paths
   - Set environment variables
   - Configure entrypoint

### Why Single-Stage?

The previous two-stage design (builder → runtime) had issues:
- Complex artifact copying between stages
- Missing CUDA runtime libraries
- LD_LIBRARY_PATH mismatches
- User/permission problems

Single-stage ensures:
- ✅ All libraries present and properly linked
- ✅ Consistent environment from build to runtime
- ✅ No artifact copying issues
- ✅ Complete CUDA toolkit available at runtime

**Trade-off:** Larger image size (~20GB vs ~3GB) for guaranteed reliability

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_HOST` | `0.0.0.0:11434` | Server listen address |
| `LD_LIBRARY_PATH` | `/usr/local/src/ollama37/build/lib/ollama:/usr/local/lib64:/usr/local/cuda-11.4/lib64:/usr/lib64` | Library search path |
| `NVIDIA_VISIBLE_DEVICES` | `all` | Which GPUs to use |
| `NVIDIA_DRIVER_CAPABILITIES` | `compute,utility` | GPU capabilities |

### Volume Mounts

- `/root/.ollama` - Model storage (use Docker volume `ollama-data`)

## GPU Support

### Supported Compute Capabilities
- **3.7** - Tesla K80 (primary target)
- **5.0-8.6** - Pascal, Volta, Turing, Ampere

### Tesla K80 Recommendations

**VRAM:** 12GB per GPU (24GB for dual-GPU K80)

**Model sizes:**
- Small (1-4B): Full precision
- Medium (7-8B): Q4_K_M quantization
- Large (13B+): Q4_0 quantization or multi-GPU

**Multi-GPU:**
```bash
docker run --gpus all ...              # Use all GPUs
docker run --gpus '"device=0"' ...     # Use specific GPU
```

## Troubleshooting

### GPU not detected
```bash
# Check GPU visibility in container
docker exec ollama37 nvidia-smi

# Check CUDA libraries
docker exec ollama37 ldconfig -p | grep cuda
```

### Model fails to load
```bash
# Check logs with CUDA debug
docker run --rm --runtime=nvidia --gpus all \
  -e OLLAMA_DEBUG=1 \
  -e GGML_CUDA_DEBUG=1 \
  ollama37:latest serve

# Check library paths
docker exec ollama37 bash -c 'echo $LD_LIBRARY_PATH'
```

### Out of memory during build
```bash
# Reduce parallel jobs in Dockerfile
# Edit line: cmake --build build -j$(nproc)
# Change to: cmake --build build -j2
```

### Port already in use
```bash
# Edit docker-compose.yml
ports:
  - "11435:11434"  # Change host port
```

## Rebuilding

### Rebuild from scratch
```bash
docker-compose down
docker rmi ollama37:latest
docker build --no-cache -t ollama37:latest -f Dockerfile ..
docker-compose up -d
```

### Rebuild with updated code
```bash
# The git clone will pull latest from GitHub
docker build -t ollama37:latest -f Dockerfile ..
docker-compose restart
```

## Documentation

- **[../CLAUDE.md](../CLAUDE.md)** - Project goals and implementation notes
- **[Upstream Ollama](https://github.com/ollama/ollama)** - Original Ollama project

## License

MIT (same as upstream Ollama)
