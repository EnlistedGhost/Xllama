# Ollama37 Docker Build System

Docker infrastructure for running Ollama on NVIDIA Tesla K80 GPUs (CUDA Compute Capability 3.7).

## Overview

This directory contains Docker build configurations for the ollama37 project, which maintains support for legacy NVIDIA Tesla K80 GPUs. The official Ollama project dropped support for Compute Capability 3.7 when transitioning to CUDA 12, but this fork preserves compatibility using CUDA 11.4.

## Directory Structure

```
docker/
├── README.md                  # This file - overview of Docker build system
├── docker-compose.yml         # Simplified deployment configuration
├── builder/                   # Build environment image
│   ├── Dockerfile             # Builder base image (CUDA 11.4 + GCC 10 + Go 1.24)
│   ├── README.md              # Builder documentation
│   └── scripts/               # Environment setup scripts
│       ├── cuda-11.4.sh       # CUDA 11.4 PATH configuration
│       ├── gcc-10.sh          # GCC 10 library paths
│       └── go-1.24.2.sh       # Go 1.24.2 PATH configuration
└── runtime/                   # Production runtime image
    ├── Dockerfile             # Multi-stage build for ollama37 binary
    └── README.md              # Runtime image documentation
```

## Components

### Builder Image (`builder/`)

The builder image provides a complete compilation environment for building ollama37 from source with Tesla K80 support.

**Base:** Rocky Linux 8  
**Key Software:**
- CUDA 11.4 Toolkit (last version supporting Compute Capability 3.7)
- NVIDIA Driver 470 (compatible with Tesla K80)
- GCC 10 (custom-built from source)
- CMake 4.0.0
- Go 1.24.2

**Purpose:** Compile ollama37 binary with optimized CUDA kernels for Tesla K80 GPUs.

See [builder/README.md](builder/README.md) for detailed information.

### Runtime Image (`runtime/`)

The runtime image is a minimal production image containing only the compiled ollama37 binary and required CUDA libraries.

**Base:** Rocky Linux 8  
**Build:** Multi-stage build using builder image  
**Size:** Optimized for production deployment  

**Purpose:** Run ollama37 server with NVIDIA GPU acceleration.

See [runtime/README.md](runtime/README.md) for usage instructions.

## Quick Start

### Option 1: Build from Source (Recommended for Development)

Build both builder and runtime images locally:

```bash
cd /home/jack/src/ollama37/docker

# Build the builder image first (takes ~30-60 minutes)
docker build -t ollama37-builder:local -f builder/Dockerfile builder/

# Build the runtime image (uses local builder)
docker build -t ollama37:local -f runtime/Dockerfile runtime/

# Run with docker-compose
docker-compose up -d
```

### Option 2: Use Pre-built Images

Pull and run pre-built images from Docker Hub:

```bash
cd /home/jack/src/ollama37/docker
docker-compose pull
docker-compose up -d
```

### Option 3: Manual Docker Run

Run the runtime image directly:

```bash
docker run -d \
  --name ollama37 \
  --runtime nvidia \
  -p 11434:11434 \
  -v ollama37-data:/root/.ollama \
  ollama37:local
```

## Usage

### Start the Server

```bash
docker-compose up -d
```

### Check Logs

```bash
docker-compose logs -f
```

### Pull a Model

```bash
docker exec -it ollama37 ollama pull llama3.2:3b
```

### Run a Chat Session

```bash
docker exec -it ollama37 ollama run llama3.2:3b
```

### API Access

The Ollama API is available at `http://localhost:11434`:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Why is the sky blue?"
}'
```

### Stop the Server

```bash
docker-compose down
```

## Tesla K80 Support

### Hardware Requirements

- **GPU:** NVIDIA Tesla K80 (Compute Capability 3.7)
- **VRAM:** 12GB per GPU (24GB for dual-GPU K80)
- **Driver:** NVIDIA Driver 470 or compatible
- **Runtime:** nvidia-docker2 or NVIDIA Container Toolkit

### Recommended Models

Based on 12GB VRAM per GPU:

| Model | Size | Quantization | Context Length |
|-------|------|--------------|----------------|
| Llama 3.2 3B | 3B | Full precision | 8K |
| Qwen 2.5 7B | 7B | Q4_K_M | 4K |
| Llama 3.1 8B | 8B | Q4_0 | 4K |
| Mistral 7B | 7B | Q4_K_M | 4K |

For larger models, use aggressive quantization (Q4_0, Q4_K_M) or multi-GPU setups.

### Multi-GPU Support

Tesla K80 dual-GPU configurations are supported:

```bash
# Use both GPUs
docker run --gpus all ...

# Use specific GPU
docker run --gpus '"device=0"' ...

# Split model across GPUs
docker run -e CUDA_VISIBLE_DEVICES=0,1 ...
```

## Build Configuration

### Environment Variables

The runtime Dockerfile uses these build arguments:

- `CC=/usr/local/bin/gcc` - Use custom GCC 10
- `CXX=/usr/local/bin/g++` - Use custom G++ 10

### CUDA Architecture Targets

The build includes Compute Capability 3.7 in `CMAKE_CUDA_ARCHITECTURES`:

```cmake
set(CMAKE_CUDA_ARCHITECTURES "37;50;61;70;75;80")
```

This ensures CUDA kernels are compiled for Tesla K80 (CC 3.7).

## Troubleshooting

### GPU Not Detected

Check NVIDIA runtime and driver installation:

```bash
docker run --rm --gpus all nvidia/cuda:11.4.0-base-ubuntu20.04 nvidia-smi
```

### Out of Memory Errors

Reduce context length or use more aggressive quantization:

```bash
docker exec ollama37 ollama run llama3.2:3b --num-ctx 2048
```

### Build Failures

Ensure sufficient disk space and memory:

- Disk space: 50GB+ recommended
- RAM: 16GB+ recommended for building
- Swap: 8GB+ recommended if RAM is limited

## Development

### Rebuilding After Changes

```bash
# Rebuild builder image
docker build --no-cache -t ollama37-builder:local -f builder/Dockerfile builder/

# Rebuild runtime image
docker build --no-cache -t ollama37:local -f runtime/Dockerfile runtime/
```

### Testing Local Builds

```bash
# Run with local image
docker run --rm -it --gpus all ollama37:local ollama --version
```

## Contributing

See the main project repository for contribution guidelines:
- [ollama37 GitHub Repository](https://github.com/dogkeeper886/ollama37)

## License

This project maintains the same license as the upstream Ollama project.

## Resources

- [Ollama Documentation](https://github.com/ollama/ollama/tree/main/docs)
- [CUDA 11.4 Documentation](https://docs.nvidia.com/cuda/archive/11.4.0/)
- [Tesla K80 Specifications](https://www.nvidia.com/en-gb/data-center/tesla-k80/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
