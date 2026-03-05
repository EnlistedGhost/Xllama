Guide the user through building ollama37. Reference `.claude/skills/build.md` for context.

If the user specifies "native", show the native build steps.
If the user specifies "docker", show the Docker container build steps.
If no argument is given, ask which build type they need.

## Native Build Steps

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

## Docker Build Steps

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
