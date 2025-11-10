FROM rockylinux/rockylinux:8

# Install CUDA toolkit 11.4
# Note: NVIDIA driver is NOT needed in builder container - only CUDA toolkit for compilation
# The host system provides the driver at runtime via --gpus flag
# dnf-plugins-core is required for the config-manager command

RUN dnf -y install dnf-plugins-core\
    && dnf -y config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo\
    && dnf -y install cuda-toolkit-11-4

# Setup CUDA path
RUN echo 'export PATH="${PATH}:/usr/local/cuda-11.4/bin"' > /etc/profile.d/cuda-11.4.sh
ENV PATH="$PATH:/usr/local/cuda-11.4/bin"

# Install gcc 10
RUN dnf -y install wget unzip bzip2 git\
    && dnf -y groupinstall "Development Tools"\
    && cd /usr/local/src\
    && wget https://github.com/gcc-mirror/gcc/archive/refs/heads/releases/gcc-10.zip\
    && unzip gcc-10.zip\
    && cd gcc-releases-gcc-10\
    && contrib/download_prerequisites\
    && mkdir /usr/local/gcc-10\
    && cd /usr/local/gcc-10\
    && /usr/local/src/gcc-releases-gcc-10/configure --disable-multilib\
    && make -j $(nproc)\
    && make install

# Setup GCC 10 library path
RUN echo '/usr/local/lib64' > /etc/ld.so.conf.d/gcc-10.conf\
    && ldconfig\
    && rm -f /usr/bin/cc\
    && ln -s /usr/local/bin/gcc /usr/bin/cc

# Install cmake 4
RUN dnf -y install openssl-devel\
    && cd /usr/local/src\
    && wget https://github.com/Kitware/CMake/releases/download/v4.0.0/cmake-4.0.0.tar.gz\
    && tar xvf cmake-4.0.0.tar.gz\
    && mkdir /usr/local/cmake-4\
    && cd /usr/local/cmake-4\
    && /usr/local/src/cmake-4.0.0/configure\
    && make -j $(nproc)\
    && make install

# Install go 1.25.3
RUN cd /usr/local\
    && wget https://go.dev/dl/go1.25.3.linux-amd64.tar.gz\
    && tar xvf go1.25.3.linux-amd64.tar.gz

# Setup Go path
RUN echo 'export PATH="${PATH}:/usr/local/go/bin"' > /etc/profile.d/go.sh
ENV PATH="$PATH:/usr/local/go/bin"

# Clone ollama37 source code
RUN cd /usr/local/src\
    && git clone https://github.com/dogkeeper886/ollama37.git

# Build ollama37
WORKDIR /usr/local/src/ollama37

# Configure with CMake (CUDA 11 preset for Tesla K80 compute capability 3.7)
RUN bash -c 'LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib64:$LD_LIBRARY_PATH \
    CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ \
    cmake --preset "CUDA 11"'

# Build C/C++/CUDA libraries
RUN bash -c 'LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:/usr/lib64:$LD_LIBRARY_PATH \
    CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ \
    cmake --build build -j$(nproc)'

# Build Go binary
RUN go build -buildvcs=false -o /usr/local/bin/ollama .

# Setup library paths for runtime
# Include: Ollama CUDA/GGML libraries, GCC 10 runtime, CUDA 11.4 libraries
ENV LD_LIBRARY_PATH=/usr/local/src/ollama37/build/lib/ollama:/usr/local/lib64:/usr/local/cuda-11.4/lib64:/usr/lib64

# Ollama server configuration
ENV OLLAMA_HOST=0.0.0.0:11434

# Expose the Ollama API port
EXPOSE 11434

# Create data directory for models
RUN mkdir -p /root/.ollama
VOLUME ["/root/.ollama"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/ollama list || exit 1

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/ollama"]
CMD ["serve"]
