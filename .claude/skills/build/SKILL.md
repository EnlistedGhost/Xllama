---
name: build
description: Build ollama37 from source (native or Docker container)
disable-model-invocation: true
argument-hint: [native|docker]
---

# Build Ollama37

## Environment
- GCC version: 10.5
- CUDA version: 11.4.4
- NVIDIA driver: 470
- Target GPU: Tesla K80 (compute capability 3.7)

## Native Build from Scratch

```bash
# Clean any previous build artifacts
rm -rf build
go clean -cache

# Configure the build (choose one)
# For all CUDA 11.4 supported architectures (37-86):
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake --preset "CUDA 11"

# For K80-only optimized build:
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake --preset "CUDA 11 K80"

# Build the C/C++/CUDA libraries
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake --build build -j$(nproc)

# Build the Go binary (with version)
OLLAMA_VERSION="2.0.1"
go build -ldflags "-X github.com/ollama/ollama/version.Version=${OLLAMA_VERSION}" -o ollama .
```

## Docker Container Build

Most code changes that affect the compiled binary or CUDA libraries require a Docker container rebuild to verify. The runtime Dockerfiles use multi-stage builds: compile in the builder image, copy only runtime artifacts (~1 GB) to a slim RockyLinux 8 minimal image.

### Local source (for testing uncommitted changes)

```bash
cd docker
make build-runtime-local
```

### From GitHub (for CI or after pushing)

```bash
cd docker
make build-runtime
```

### Force rebuild without cache

```bash
cd docker
make build-runtime-local-no-cache
# or
make build-runtime-no-cache
```

### Full rebuild (builder + runtime)

```bash
cd docker
make build
```

**Build times:**
- Builder image: ~90 min (first time), cached thereafter
- Runtime image: ~10 min

See `docker/README.md` for full Docker documentation.
