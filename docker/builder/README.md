# Ollama37 Builder Image

This directory contains the Dockerfile for building the `ollama37-builder:latest` image.

## What's Inside

The builder image includes:
- **Base**: `nvidia/cuda:11.4.3-devel-rockylinux8`
- **GCC 10**: `gcc-toolset-10` (required by CUDA 11.4)
- **CMake**: System package
- **Go**: System package

## Building the Builder Image

The builder image is **automatically built** by the Makefile when you run `make build` for the first time.

To manually build the builder image:

```bash
cd /home/jack/Documents/ollama37/docker
make build-builder
```

Or using Docker directly:

```bash
cd /home/jack/Documents/ollama37/docker/builder
docker build -t ollama37-builder:latest .
```

## Using the Builder Image

The Makefile handles this automatically, but for reference:

```bash
# Start builder container with GPU access
docker run --rm -d \
  --name ollama37-builder \
  --runtime=nvidia \
  --gpus all \
  ollama37-builder:latest \
  sleep infinity

# Use the container
docker exec -it ollama37-builder bash
```

## Customization

If you need to modify the builder (e.g., change CUDA version, add packages):

1. Edit `Dockerfile` in this directory
2. Rebuild: `make clean-builder build-builder`
3. Build your project: `make build`

## Archived Builder

The `archived/` subdirectory contains an older Dockerfile that built GCC and CMake from source (~80 minutes). The current version uses Rocky Linux system packages for much faster builds (~5 minutes).