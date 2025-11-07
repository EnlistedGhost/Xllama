# Dockerfile for Ollama37 Runtime Image
#
# This creates a minimal runtime-only image from pre-built artifacts.
# The artifacts should be built first using the Makefile in ../
#
# Build context should be the project root (../..) so we can access docker/output/
#
# Usage:
#   cd /path/to/ollama37
#   make -C docker build           # Build the binary first
#   make -C docker build-runtime   # Create the runtime image

FROM nvidia/cuda:11.4.3-runtime-rockylinux8

# Install minimal runtime dependencies
# Note: Not running 'dnf update' to keep base image stable and build faster
RUN dnf -y install \
    libgomp \
    libstdc++ \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Create directory structure
RUN mkdir -p /usr/local/bin /usr/local/lib/ollama

# Copy the ollama binary from build output
COPY docker/output/ollama /usr/local/bin/ollama

# Copy all shared libraries from build output
COPY docker/output/lib/ /usr/local/lib/ollama/

# Prepend our library path to the existing LD_LIBRARY_PATH
# Base image already has: /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV LD_LIBRARY_PATH="/usr/local/lib/ollama:${LD_LIBRARY_PATH}"

# Base image already sets these, but we can override if needed:
# NVIDIA_DRIVER_CAPABILITIES=compute,utility
# NVIDIA_VISIBLE_DEVICES=all

# Ollama server configuration
ENV OLLAMA_HOST=0.0.0.0:11434

# Expose the Ollama API port
EXPOSE 11434

# Create a data directory for models
RUN mkdir -p /root/.ollama
VOLUME ["/root/.ollama"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/ollama list || exit 1

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/ollama"]
CMD ["serve"]
