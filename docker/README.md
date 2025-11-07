# Ollama37 Docker Build System

**Makefile-based build system for Ollama with CUDA 11.4 and Compute Capability 3.7 support (Tesla K80)**

## Overview

This fork maintains support for legacy NVIDIA GPUs (Tesla K80, Compute Capability 3.7) using CUDA 11.4 and GCC 10. The upstream Ollama project dropped CC 3.7 support when transitioning to CUDA 12.

### Key Features

- GPU-enabled build container with automatic architecture detection
- Makefile orchestration for entire workflow
- Production-ready runtime image (3.1GB)
- Docker Compose support

## Prerequisites

- Docker with NVIDIA Container Runtime
- NVIDIA GPU drivers (470+ for Tesla K80)
- Verify GPU access:
  ```bash
  docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.4.3-base-rockylinux8 nvidia-smi
  ```

## Quick Start

### 1. Build the Builder Image (First Time Only)

```bash
cd /home/jack/Documents/ollama37/docker
make build-builder
```

This builds the `ollama37-builder:latest` image containing CUDA 11.4, GCC 10, CMake, and Go. Takes ~5 minutes first time.

### 2. Build Ollama

```bash
# Build binary and libraries (~7 minutes)
make build

# Create runtime Docker image (~2 minutes)
make build-runtime
```

### 3. Run

```bash
# Option A: Using docker-compose (recommended)
docker-compose up -d
curl http://localhost:11434/api/tags

# Option B: Using Makefile
make run-runtime
curl http://localhost:11434/api/tags
```

## Directory Structure

```
docker/
├── Makefile              # Build orchestration
├── docker-compose.yml    # Deployment configuration
├── builder/
│   └── Dockerfile        # Builder image definition
├── runtime/
│   └── Dockerfile        # Runtime image definition
└── output/               # Build artifacts (created by make build)
    ├── ollama           # Binary (61MB)
    └── lib/             # Libraries (109MB)
```

## Make Targets

### Builder Image
| Command | Description |
|---------|-------------|
| `make build-builder` | Build builder Docker image |
| `make clean-builder` | Remove builder image |

### Build
| Command | Description |
|---------|-------------|
| `make build` | Build binary and libraries |
| `make test` | Test the built binary |
| `make shell` | Open shell in builder container |
| `make clean` | Remove output artifacts |
| `make clean-all` | Clean everything + stop containers |

### Runtime
| Command | Description |
|---------|-------------|
| `make build-runtime` | Build Docker runtime image |
| `make run-runtime` | Start runtime container |
| `make stop-runtime` | Stop runtime container |
| `make clean-runtime` | Remove image and volumes |

### Help
```bash
make help               # Show all available targets
```

## Usage Examples

### Development Workflow

```bash
# First time setup
make build-builder
make build
make test

# After code changes
make build
make build-runtime
make run-runtime
```

### Production Deployment

```bash
make build-builder
make build build-runtime
docker-compose up -d
```

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
# List/pull/run models
docker exec ollama37-runtime ollama list
docker exec ollama37-runtime ollama pull gemma3:4b
docker exec ollama37-runtime ollama run gemma3:4b "Hello!"
```

## GPU Support

### Supported Compute Capabilities
- **3.7** - Tesla K80 (primary target)
- **5.0-8.6** - Pascal, Volta, Turing, Ampere

### Tesla K80 Recommendations

**VRAM:** 12GB per GPU (24GB for dual-GPU K80)

**Model sizes:**
- Small (3-4B): Full precision
- Medium (7-8B): Q4_K_M quantization
- Large (13B+): Q4_0 quantization or multi-GPU

**Multi-GPU:**
```bash
docker run --gpus all ...              # Use all GPUs
docker run --gpus '"device=0"' ...     # Use specific GPU
```

## Configuration

### Environment Variables (docker-compose.yml)

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_HOST` | `0.0.0.0:11434` | Server listen address |
| `OLLAMA_MODELS` | `/root/.ollama/models` | Model storage path |
| `NVIDIA_VISIBLE_DEVICES` | `all` | Which GPUs to use |

### Makefile Variables

```bash
make build CMAKE_PRESET="CUDA 11 K80"         # Use different preset
make build NPROC=4                            # Control parallel jobs
make build-runtime RUNTIME_IMAGE=my-ollama    # Custom image name
```

## Troubleshooting

### GPU not detected during build
```bash
make shell
nvidia-smi    # Should show your GPU
```

### Out of memory during build
```bash
make build NPROC=2    # Reduce parallel jobs
```

### Container won't start
```bash
docker logs ollama37-runtime
# or
docker-compose logs
```

### GPU not accessible in runtime
```bash
docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

### Port already in use
```bash
# Edit docker-compose.yml
ports:
  - "11435:11434"  # Change host port
```

## Advanced

### Custom Builder Image

The builder is automatically built from `builder/Dockerfile` when running `make build` for the first time.

To customize (e.g., change CUDA version, add dependencies):

```bash
vim docker/builder/Dockerfile
make clean-builder build-builder
make build
```

See `builder/README.md` for details.

### Clean Docker Build Cache

```bash
# Remove all build cache
docker builder prune -af

# Nuclear option (cleans everything)
docker system prune -af
```

## Documentation

- **[../CLAUDE.md](../CLAUDE.md)** - Project goals and implementation notes
- **[builder/README.md](builder/README.md)** - Builder image documentation

## License

MIT (same as upstream Ollama)
