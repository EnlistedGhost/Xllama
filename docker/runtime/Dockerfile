# Ollama37 Runtime Image
# Two-stage build: compile stage builds the binary, runtime stage packages it
# Both stages use ollama37-builder base to maintain identical library paths
# This ensures the compiled binary can find all required runtime libraries

# Stage 1: Compile ollama37 from source
FROM ollama37-builder as builder

# Clone ollama37 source code from GitHub
RUN cd /usr/local/src\
    && git clone https://github.com/dogkeeper886/ollama37.git

# Set working directory for build
WORKDIR /usr/local/src/ollama37

# Configure build with CMake
# Use "CUDA 11" preset for Tesla K80 compute capability 3.7 support
# Set LD_LIBRARY_PATH to find GCC 10 and system libraries during build
RUN bash -c 'LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib64:$LD_LIBRARY_PATH \
    CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ \
    cmake --preset "CUDA 11"'

# Build C/C++/CUDA libraries with CMake
# Compile all GGML CUDA kernels and Ollama native libraries
RUN bash -c 'LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib64:$LD_LIBRARY_PATH \
    CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ \
    cmake --build build -j$(nproc)'

# Build Go binary
# VCS info is embedded automatically since we cloned from git
RUN go build -o /usr/local/bin/ollama .


# Stage 2: Runtime environment
# Use ollama37-builder as base to maintain library path compatibility
# The compiled binary has hardcoded library paths that match this environment
FROM ollama37-builder as runtime

# Copy the entire source directory including compiled libraries
# This preserves the exact directory structure the binary expects
COPY --from=builder /usr/local/src/ollama37 /usr/local/src/ollama37

# Copy the ollama binary to system bin directory
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Setup library paths for runtime
# The binary expects libraries in these exact paths:
#   /usr/local/src/ollama37/build/lib/ollama - Ollama CUDA/GGML libraries
#   /usr/local/lib64 - GCC 10 runtime libraries (libstdc++, libgcc_s)
#   /usr/local/cuda-11.4/lib64 - CUDA 11.4 runtime libraries
#   /usr/lib64 - System libraries
ENV LD_LIBRARY_PATH=/usr/local/src/ollama37/build/lib/ollama:/usr/local/lib64:/usr/local/cuda-11.4/lib64:/usr/lib64

# Configure Ollama server to listen on all interfaces
ENV OLLAMA_HOST=0.0.0.0:11434

# Expose Ollama API port
EXPOSE 11434

# Create persistent volume for model storage
# Models downloaded by Ollama will be stored here
RUN mkdir -p /root/.ollama
VOLUME ["/root/.ollama"]

# Configure health check to verify Ollama is running
# Uses 'ollama list' command to check if the service is responsive
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/ollama list || exit 1

# Set entrypoint and default command
# Container runs 'ollama serve' by default to start the API server
ENTRYPOINT ["/usr/local/bin/ollama"]
CMD ["serve"]
