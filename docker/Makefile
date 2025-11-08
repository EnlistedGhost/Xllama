# Makefile for building Ollama with GPU-enabled builder container
#
# This Makefile uses a pre-built builder container with CUDA support and GPU access
# to compile Ollama with compute capability 3.7 support (Tesla K80).
#
# Usage:
#   make build          - Build ollama binary and libraries
#   make clean          - Remove build artifacts from host
#   make clean-all      - Remove build artifacts and stop/remove containers
#   make shell          - Open a shell in the builder container
#   make test           - Test the built binary

# Configuration
BUILDER_IMAGE := ollama37-builder
BUILDER_TAG := latest
BUILDER_DOCKERFILE := $(SOURCE_DIR)/docker/builder/Dockerfile
CONTAINER_NAME := ollama37-builder
RUNTIME_IMAGE := ollama37-runtime
RUNTIME_TAG := latest
SOURCE_DIR := $(shell cd .. && pwd)
BUILD_DIR := $(SOURCE_DIR)/build
DIST_DIR := $(SOURCE_DIR)/dist
OUTPUT_DIR := $(SOURCE_DIR)/docker/output
RUNTIME_DOCKERFILE := $(SOURCE_DIR)/docker/runtime/Dockerfile

# CMake preset to use
CMAKE_PRESET := CUDA 11

# Detect number of CPU cores for parallel compilation
NPROC := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

.PHONY: all build clean clean-all shell test build-builder clean-builder ensure-builder start-builder stop-builder copy-source run-cmake run-build run-go-build copy-artifacts build-runtime run-runtime stop-runtime clean-runtime

# Default target
all: build

# ===== Builder Image Targets =====

# Build the builder Docker image from builder/Dockerfile
build-builder:
	@echo "→ Building builder Docker image..."
	@echo "  Building Docker image $(BUILDER_IMAGE):$(BUILDER_TAG)..."
	@cd $(SOURCE_DIR)/docker/builder && docker build \
		-t $(BUILDER_IMAGE):$(BUILDER_TAG) \
		.
	@echo ""
	@echo "✓ Builder image built successfully!"
	@echo "  Image: $(BUILDER_IMAGE):$(BUILDER_TAG)"
	@echo ""
	@echo "To use this custom builder:"
	@echo "  make build BUILDER_IMAGE=$(BUILDER_IMAGE):$(BUILDER_TAG)"

# Clean builder image
clean-builder:
	@echo "→ Cleaning builder image..."
	@docker rmi $(BUILDER_IMAGE):$(BUILDER_TAG) 2>/dev/null || echo "  No builder image to remove"
	@echo "  Builder image cleaned"

# ===== Build Targets =====

# Main build target - orchestrates the entire build process
build: ensure-builder start-builder copy-source run-cmake run-build run-go-build copy-artifacts
	@echo ""
	@echo "✓ Build completed successfully!"
	@echo "  Binary:    $(OUTPUT_DIR)/ollama"
	@echo "  Libraries: $(OUTPUT_DIR)/lib/"
	@echo ""
	@echo "To test the binary:"
	@echo "  cd $(OUTPUT_DIR) && ./ollama --version"

# Ensure builder image exists (build if not present)
ensure-builder:
	@if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$(BUILDER_IMAGE):$(BUILDER_TAG)$$"; then \
		echo "→ Builder image not found. Building $(BUILDER_IMAGE):$(BUILDER_TAG)..."; \
		$(MAKE) build-builder; \
	else \
		echo "→ Builder image $(BUILDER_IMAGE):$(BUILDER_TAG) already exists"; \
	fi

# Start the builder container with GPU access
start-builder:
	@echo "→ Starting builder container with GPU access..."
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(CONTAINER_NAME)$$"; then \
		echo "  Container $(CONTAINER_NAME) already exists, checking status..."; \
		if docker ps --format '{{.Names}}' | grep -q "^$(CONTAINER_NAME)$$"; then \
			echo "  Container is already running"; \
		else \
			echo "  Starting existing container..."; \
			docker start $(CONTAINER_NAME); \
		fi \
	else \
		echo "  Creating new container..."; \
		docker run --rm -d \
			--name $(CONTAINER_NAME) \
			--runtime=nvidia \
			--gpus all \
			$(BUILDER_IMAGE) \
			sleep infinity; \
		sleep 2; \
		docker exec $(CONTAINER_NAME) nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader; \
	fi

# Stop and remove the builder container
stop-builder:
	@echo "→ Stopping builder container..."
	@if docker ps --format '{{.Names}}' | grep -q "^$(CONTAINER_NAME)$$"; then \
		docker stop $(CONTAINER_NAME); \
		echo "  Container stopped"; \
	else \
		echo "  Container not running"; \
	fi

# Copy source code to the container
copy-source: start-builder
	@echo "→ Copying source code to container..."
	@docker cp $(SOURCE_DIR)/. $(CONTAINER_NAME):/usr/local/src/ollama37/
	@echo "→ Cleaning any host build artifacts from container..."
	@docker exec $(CONTAINER_NAME) rm -rf /usr/local/src/ollama37/build /usr/local/src/ollama37/ollama /usr/local/src/ollama37/dist
	@echo "  Source code copied (clean build environment)"

# Run CMake configuration
run-cmake: copy-source
	@echo "→ Running CMake configuration (preset: $(CMAKE_PRESET))..."
	@docker exec -w /usr/local/src/ollama37 $(CONTAINER_NAME) \
		scl enable gcc-toolset-10 -- bash -c 'cmake --preset "$(CMAKE_PRESET)"'

# Run CMake build (C/C++/CUDA compilation)
run-build: run-cmake
	@echo "→ Building C/C++/CUDA libraries (using $(NPROC) cores)..."
	@docker exec -w /usr/local/src/ollama37 $(CONTAINER_NAME) \
		scl enable gcc-toolset-10 -- bash -c 'cmake --build build -j$(NPROC)'

# Run Go build
run-go-build: run-build
	@echo "→ Building Go binary..."
	@docker exec -w /usr/local/src/ollama37 $(CONTAINER_NAME) \
		scl enable gcc-toolset-10 -- bash -c 'go build -o ollama .'

# Copy build artifacts from container to host
copy-artifacts: run-go-build
	@echo "→ Copying build artifacts to host..."
	@mkdir -p $(OUTPUT_DIR)/lib
	@docker cp $(CONTAINER_NAME):/usr/local/src/ollama37/ollama $(OUTPUT_DIR)/
	@docker cp $(CONTAINER_NAME):/usr/local/src/ollama37/build/lib/ollama/. $(OUTPUT_DIR)/lib/
	@echo "  Artifacts copied to $(OUTPUT_DIR)"
	@echo ""
	@echo "  Binary: $(OUTPUT_DIR)/ollama"
	@ls -lh $(OUTPUT_DIR)/ollama
	@echo ""
	@echo "  Libraries:"
	@ls -lh $(OUTPUT_DIR)/lib/

# Open an interactive shell in the builder container
shell: start-builder
	@echo "→ Opening shell in builder container..."
	@docker exec -it -w /usr/local/src/ollama37 $(CONTAINER_NAME) \
		scl enable gcc-toolset-10 -- bash

# Test the built binary
test: build
	@echo "→ Testing ollama binary..."
	@cd $(OUTPUT_DIR) && LD_LIBRARY_PATH=$$PWD/lib:$$LD_LIBRARY_PATH ./ollama --version

# Clean build artifacts from host
clean:
	@echo "→ Cleaning build artifacts from host..."
	@rm -rf $(OUTPUT_DIR)
	@echo "  Cleaned $(OUTPUT_DIR)"

# Clean everything including container
clean-all: clean stop-builder
	@echo "→ Cleaning build directory in source..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)
	@echo "  All cleaned"

# ===== Runtime Image Targets =====

# Build the runtime Docker image from artifacts
build-runtime:
	@echo "→ Building runtime Docker image..."
	@if [ ! -f "$(OUTPUT_DIR)/ollama" ]; then \
		echo "Error: ollama binary not found in $(OUTPUT_DIR)"; \
		echo "Run 'make build' first to create the artifacts"; \
		exit 1; \
	fi
	@if [ ! -d "$(OUTPUT_DIR)/lib" ]; then \
		echo "Error: lib directory not found in $(OUTPUT_DIR)"; \
		echo "Run 'make build' first to create the artifacts"; \
		exit 1; \
	fi
	@echo "  Building Docker image $(RUNTIME_IMAGE):$(RUNTIME_TAG)..."
	@docker build \
		-f $(RUNTIME_DOCKERFILE) \
		-t $(RUNTIME_IMAGE):$(RUNTIME_TAG) \
		$(SOURCE_DIR)
	@echo ""
	@echo "✓ Runtime image built successfully!"
	@echo "  Image: $(RUNTIME_IMAGE):$(RUNTIME_TAG)"
	@echo ""
	@$(MAKE) stop-builder
	@echo ""
	@echo "To run the image:"
	@echo "  make run-runtime"
	@echo ""
	@echo "Or manually:"
	@echo "  docker run --rm -it --runtime=nvidia --gpus all -p 11434:11434 $(RUNTIME_IMAGE):$(RUNTIME_TAG)"

# Run the runtime container
run-runtime:
	@echo "→ Starting runtime container..."
	@if docker ps -a --format '{{.Names}}' | grep -q "^ollama37-runtime$$"; then \
		echo "  Stopping existing container..."; \
		docker stop ollama37-runtime 2>/dev/null || true; \
		docker rm ollama37-runtime 2>/dev/null || true; \
	fi
	@echo "  Starting new container..."
	@docker run -d \
		--name ollama37-runtime \
		--runtime=nvidia \
		--gpus all \
		-p 11434:11434 \
		-v ollama-data:/root/.ollama \
		$(RUNTIME_IMAGE):$(RUNTIME_TAG)
	@sleep 2
	@echo ""
	@echo "✓ Runtime container started!"
	@echo "  Container: ollama37-runtime"
	@echo "  API: http://localhost:11434"
	@echo ""
	@echo "Check logs:"
	@echo "  docker logs -f ollama37-runtime"
	@echo ""
	@echo "Test the API:"
	@echo "  curl http://localhost:11434/api/tags"
	@echo ""
	@echo "Stop the container:"
	@echo "  make stop-runtime"

# Stop the runtime container
stop-runtime:
	@echo "→ Stopping runtime container..."
	@if docker ps --format '{{.Names}}' | grep -q "^ollama37-runtime$$"; then \
		docker stop ollama37-runtime; \
		docker rm ollama37-runtime; \
		echo "  Container stopped and removed"; \
	else \
		echo "  Container not running"; \
	fi

# Clean runtime image
clean-runtime:
	@echo "→ Cleaning runtime image..."
	@docker rmi $(RUNTIME_IMAGE):$(RUNTIME_TAG) 2>/dev/null || echo "  No runtime image to remove"
	@docker volume rm ollama-data 2>/dev/null || echo "  No volume to remove"
	@echo "  Runtime image cleaned"

# Help target
help:
	@echo "Ollama Build System (with GPU-enabled builder)"
	@echo ""
	@echo "Builder Image Targets:"
	@echo "  make build-builder  - Build custom builder Docker image"
	@echo "  make clean-builder  - Remove builder image"
	@echo ""
	@echo "Build Targets:"
	@echo "  make build          - Build ollama binary and libraries (default)"
	@echo "  make clean          - Remove build artifacts from host"
	@echo "  make clean-all      - Remove all build artifacts and stop container"
	@echo "  make shell          - Open a shell in the builder container"
	@echo "  make test           - Test the built binary"
	@echo ""
	@echo "Runtime Image Targets:"
	@echo "  make build-runtime  - Build Docker runtime image from artifacts"
	@echo "  make run-runtime    - Start the runtime container"
	@echo "  make stop-runtime   - Stop the runtime container"
	@echo "  make clean-runtime  - Remove runtime image and volumes"
	@echo ""
	@echo "  make help           - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  BUILDER_IMAGE:   $(BUILDER_IMAGE):$(BUILDER_TAG)"
	@echo "  RUNTIME_IMAGE:   $(RUNTIME_IMAGE):$(RUNTIME_TAG)"
	@echo "  CONTAINER_NAME:  $(CONTAINER_NAME)"
	@echo "  CMAKE_PRESET:    $(CMAKE_PRESET)"
	@echo "  PARALLEL_JOBS:   $(NPROC)"
	@echo ""
	@echo "Environment:"
	@echo "  SOURCE_DIR:      $(SOURCE_DIR)"
	@echo "  OUTPUT_DIR:      $(OUTPUT_DIR)"
