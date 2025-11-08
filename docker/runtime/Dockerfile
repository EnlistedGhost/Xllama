FROM rockylinux/rockylinux:8

# Install only CUDA runtime libraries (not the full toolkit)
# The host system provides the NVIDIA driver at runtime via --gpus flag
RUN dnf -y install dnf-plugins-core\
    && dnf -y config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo\
    && dnf -y install cuda-cudart-11-4 libcublas-11-4 \
    && dnf clean all

# Create directory structure
RUN mkdir -p /usr/local/bin /usr/local/lib/ollama

# Copy the ollama binary from build output
COPY docker/output/ollama /usr/local/bin/ollama

# Copy all shared libraries from build output (includes ollama libs + GCC 10 runtime libs)
COPY docker/output/lib/ /usr/local/lib/ollama/

# Set library path to include our ollama libraries first
# This includes:
#   - Ollama CUDA/GGML libraries
#   - GCC 10 runtime libraries (libstdc++.so.6, libgcc_s.so.1)
#   - System CUDA libraries
ENV LD_LIBRARY_PATH=/usr/local/lib/ollama:/usr/local/cuda-11.4/lib64:/usr/lib64

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
