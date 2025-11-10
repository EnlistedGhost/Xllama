# Makefile for Ollama37 Docker Build System
#
# This Makefile manages the two-stage Docker build process:
#   1. Builder image: Base environment with CUDA 11.4, GCC 10, CMake 4, Go 1.25.3
#   2. Runtime image: Two-stage build that compiles and packages Ollama
#
# The runtime Dockerfile handles:
#   - Cloning source from GitHub
#   - CMake configuration and C/C++/CUDA compilation
#   - Go binary compilation
#   - Packaging runtime environment
#
# Usage:
#   make build          - Build builder and runtime images (default)
#   make build-builder  - Build only the builder image
#   make build-runtime  - Build only the runtime image
#   make clean          - Remove all Docker images
#   make help           - Show help message
#
# To run the container, use docker-compose:
#   docker-compose up -d
#   docker-compose logs -f
#   docker-compose down

# Configuration
BUILDER_IMAGE := ollama37-builder
BUILDER_TAG := latest
RUNTIME_IMAGE := ollama37
RUNTIME_TAG := latest
SOURCE_DIR := $(shell cd .. && pwd)
BUILDER_DOCKERFILE := $(SOURCE_DIR)/docker/builder/Dockerfile
RUNTIME_DOCKERFILE := $(SOURCE_DIR)/docker/runtime/Dockerfile

# Docker build context directories
BUILDER_CONTEXT := $(SOURCE_DIR)/docker/builder
RUNTIME_CONTEXT := $(SOURCE_DIR)

.PHONY: all build build-builder build-runtime ensure-builder clean help

# Default target
all: build

# Build both builder and runtime images
build: build-builder build-runtime
	@echo ""
	@echo "✓ All images built successfully!"
	@echo "  Builder: $(BUILDER_IMAGE):$(BUILDER_TAG)"
	@echo "  Runtime: $(RUNTIME_IMAGE):$(RUNTIME_TAG)"
	@echo ""
	@echo "To start the Ollama server:"
	@echo "  docker-compose up -d"
	@echo ""
	@echo "View logs:"
	@echo "  docker-compose logs -f"
	@echo ""
	@echo "Stop the server:"
	@echo "  docker-compose down"

# Build the builder base image
build-builder:
	@echo "→ Building builder image..."
	@echo "  Image: $(BUILDER_IMAGE):$(BUILDER_TAG)"
	@echo "  Dockerfile: $(BUILDER_DOCKERFILE)"
	@echo ""
	@docker build \
		-f $(BUILDER_DOCKERFILE) \
		-t $(BUILDER_IMAGE):$(BUILDER_TAG) \
		$(BUILDER_CONTEXT)
	@echo ""
	@echo "✓ Builder image built successfully!"

# Build the runtime image (requires builder image)
build-runtime: ensure-builder
	@echo "→ Building runtime image..."
	@echo "  Image: $(RUNTIME_IMAGE):$(RUNTIME_TAG)"
	@echo "  Dockerfile: $(RUNTIME_DOCKERFILE)"
	@echo ""
	@echo "  This will:"
	@echo "    - Clone ollama37 source from GitHub"
	@echo "    - Configure with CMake (CUDA 11 preset)"
	@echo "    - Compile C/C++/CUDA libraries"
	@echo "    - Build Go binary"
	@echo "    - Package runtime environment"
	@echo ""
	@docker build \
		-f $(RUNTIME_DOCKERFILE) \
		-t $(RUNTIME_IMAGE):$(RUNTIME_TAG) \
		$(RUNTIME_CONTEXT)
	@echo ""
	@echo "✓ Runtime image built successfully!"
	@echo ""
	@echo "To start the Ollama server:"
	@echo "  docker-compose up -d"

# Ensure builder image exists (build if not present)
ensure-builder:
	@if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$(BUILDER_IMAGE):$(BUILDER_TAG)$$"; then \
		echo "→ Builder image not found. Building $(BUILDER_IMAGE):$(BUILDER_TAG)..."; \
		echo ""; \
		$(MAKE) build-builder; \
		echo ""; \
	fi

# Remove all Docker images
clean:
	@echo "→ Removing Docker images..."
	@docker rmi $(RUNTIME_IMAGE):$(RUNTIME_TAG) 2>/dev/null || echo "  No runtime image to remove"
	@docker rmi $(BUILDER_IMAGE):$(BUILDER_TAG) 2>/dev/null || echo "  No builder image to remove"
	@echo ""
	@echo "✓ Images removed"
	@echo ""
	@echo "Note: To remove containers and volumes, use:"
	@echo "  docker-compose down -v"

# Show help message
help:
	@echo "Ollama37 Docker Build System"
	@echo ""
	@echo "Build Targets:"
	@echo "  make build          - Build builder and runtime images (default)"
	@echo "  make build-builder  - Build only the builder base image"
	@echo "  make build-runtime  - Build only the runtime image"
	@echo "  make clean          - Remove all Docker images"
	@echo "  make help           - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  BUILDER_IMAGE:   $(BUILDER_IMAGE):$(BUILDER_TAG)"
	@echo "  RUNTIME_IMAGE:   $(RUNTIME_IMAGE):$(RUNTIME_TAG)"
	@echo ""
	@echo "Dockerfiles:"
	@echo "  Builder:         $(BUILDER_DOCKERFILE)"
	@echo "  Runtime:         $(RUNTIME_DOCKERFILE)"
	@echo ""
	@echo "Build Architecture:"
	@echo "  1. Builder image: Base environment (CUDA 11.4, GCC 10, CMake 4, Go 1.25.3)"
	@echo "  2. Runtime image: Two-stage build (compile + package)"
	@echo "     - Stage 1: Clone source, compile C/C++/CUDA/Go"
	@echo "     - Stage 2: Package runtime with compiled binaries"
	@echo ""
	@echo "Container Management (use docker-compose):"
	@echo "  docker-compose up -d        - Start Ollama server"
	@echo "  docker-compose logs -f      - View logs"
	@echo "  docker-compose down         - Stop server"
	@echo "  docker-compose down -v      - Stop and remove volumes"
