# Manual Build Guide for Ollama37

This document provides comprehensive instructions for building Ollama37 from source on various platforms, specifically optimized for Tesla K80 and CUDA Compute Capability 3.7 hardware.

## ⚠️ Important: Kernel Compatibility Notice

Recent kernel updates in **Fedora, Ubuntu, and Rocky Linux** have **broken compatibility** with:
- NVIDIA Driver 470 (required for Tesla K80 / Compute Capability 3.7)
- CUDA 11.4 nvcc compiler

**Solution**: Compile a compatible kernel from source (Linux 5.14.x) before installing NVIDIA drivers.

**Recommended Linux Distribution**: **Rocky Linux 9**
- Rocky Linux 8 has docker-ce compatibility issues
- Rocky Linux 9 provides better stability and container support

---

## Native Build Overview

For native builds on **Rocky Linux 9**, you'll need to follow these steps in order:

**Installation Steps:**
1. **Compile Custom Kernel** (Linux 5.14.x) - Required for NVIDIA 470 compatibility
2. **Install NVIDIA Driver 470 & CUDA 11.4** - Tesla K80 GPU support
3. **Install CMake 4.0** - Build system
4. **Install Go 1.24.2** - Go compiler
5. **Install GCC 10** (Optional - only if compiling ollama37 from source)
6. **Compile Ollama37** (Optional - if not using pre-built binaries)

**Quick Native Build (after prerequisites):**

```bash
# Clone repository
git clone https://github.com/dogkeeper886/ollama37
cd ollama37

# If compiling from source (requires GCC 10):
cmake -B build
cmake --build build -j$(nproc)
go build -o ollama .

# If using pre-built binary (GCC 10 not required):
# Just download and run the ollama binary
```

---

## Detailed Installation Guide for Rocky Linux 9

### Step 1: Kernel Compilation (Required for NVIDIA 470 Compatibility)

#### Why Compile a Custom Kernel?

Recent kernel updates in Rocky Linux 9, Fedora, and Ubuntu have **broken compatibility** with:
- NVIDIA Driver 470 (required for Tesla K80 / Compute Capability 3.7)
- CUDA 11.4 nvcc compiler

**Solution**: Use Linux kernel 5.14.x, which maintains stable NVIDIA 470 driver support.

#### Prerequisites

**System Requirements:**
- Rocky Linux 9 (clean installation recommended)
- Root privileges
- At least 20GB free disk space
- Stable internet connection

**Install Build Tools:**
```bash
dnf -y groupinstall "Development Tools"
dnf -y install ncurses-devel
```

#### Download Kernel Source

1. **Navigate to source directory:**
   ```bash
   cd /usr/src/kernels
   ```

2. **Download Linux 5.14.x kernel:**
   ```bash
   wget https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.14.tar.xz
   ```

   > **Note**: Check [kernel.org](https://www.kernel.org/pub/linux/kernel/v5.x/) for the latest 5.14.x stable release.

3. **Extract the archive:**
   ```bash
   tar xvf linux-5.14.tar.xz
   cd linux-5.14
   ```

#### Configure Kernel

1. **Copy existing kernel configuration:**
   ```bash
   # First, check available kernel configurations
   ls /usr/src/kernels
   
   # Copy config from the running kernel (adjust version as needed)
   # Example: cp /usr/src/kernels/5.14.0-570.52.1.el9_6.x86_64/.config .config
   cp /usr/src/kernels/$(uname -r)/.config .config
   ```
2. **Open menuconfig to adjust settings:**
   ```bash
   make menuconfig
   ```

4. **Required Configuration Changes:**

   Navigate and **DISABLE** the following options:

   **a) Disable Module Signature Verification:**
   ```
   Enable loadable module support
     → [ ] Module signature verification  (press N to disable)
   ```

   **b) Disable Trusted Keys:**
   ```
   Cryptographic API
     → Certificates for signature checking
       → [ ] Provide system-wide ring of trusted keys  (press N)
       → System trusted keys filename = "" (delete any content, leave empty)
   ```

   **c) Disable BTF Debug Info:**
   ```
   Kernel hacking
     → Compile-time checks and compiler options
       → [ ] Generate BTF typeinfo  (press N to disable CONFIG_DEBUG_INFO_BTF)
   ```

   > **Why disable these?**
   > - Module signatures: Prevents loading unsigned NVIDIA proprietary driver
   > - Trusted keys: Conflicts with out-of-tree driver compilation
   > - BTF debug: Can cause build failures and is unnecessary for production use

5. **Save configuration:**
   - Press `<Save>`
   - Confirm default filename `.config`
   - Press `<Exit>` to quit menuconfig

#### Compile Kernel

1. **Clean previous builds (if any):**
   ```bash
   make clean
   ```

2. **Compile kernel (using all CPU cores):**
   ```bash
   make -j$(nproc)
   ```

   > **Estimated time**: 30-60 minutes depending on CPU performance

3. **Compile kernel modules:**
   ```bash
   make modules -j$(nproc)
   ```

4. **Install kernel modules:**
   ```bash
   make modules_install
   ```

5. **Install kernel:**
   ```bash
   make install
   ```

#### Configure Bootloader

1. **Update GRUB configuration:**
   ```bash
   grub2-mkconfig -o /boot/grub2/grub.cfg
   ```

2. **Set new kernel as default (optional):**
   ```bash
   # List available kernels
   grubby --info=ALL | grep ^kernel

   # Set default to newly installed kernel
   grubby --set-default /boot/vmlinuz-5.14.21
   ```

3. **Verify default kernel:**
   ```bash
   grubby --default-kernel
   # Should output: /boot/vmlinuz-5.14.21
   ```

#### Reboot and Verify

1. **Reboot system:**
   ```bash
   reboot
   ```

2. **After reboot, verify kernel version:**
   ```bash
   uname -r
   # Should output: 5.14.21
   ```

3. **Check kernel configuration:**
   ```bash
   # Verify BTF is disabled
   grep CONFIG_DEBUG_INFO_BTF /boot/config-$(uname -r)
   # Should output: # CONFIG_DEBUG_INFO_BTF is not set

   # Verify module signature is disabled
   grep CONFIG_MODULE_SIG /boot/config-$(uname -r)
   # Should output: # CONFIG_MODULE_SIG is not set
   ```

#### Troubleshooting Kernel Compilation

**Issue: BTF-related build errors**
```
BTF: .tmp_vmlinux.btf: pahole (pahole) is not available
Failed to generate BTF for vmlinux
```

**Solution:**
- Disable `CONFIG_DEBUG_INFO_BTF` in menuconfig (see step 4c above)

---

**Issue: Module signing key errors**
```
Can't read private key
```

**Solution:**
- Disable `CONFIG_MODULE_SIG_ALL` and clear `CONFIG_SYSTEM_TRUSTED_KEYS` in menuconfig
- Ensure the "System trusted keys filename" field is completely empty

---

**Issue: Kernel doesn't appear in GRUB menu**

**Solution:**
```bash
# Regenerate GRUB config
grub2-mkconfig -o /boot/grub2/grub.cfg

# Check if kernel is listed
grubby --info=ALL
```

---

**Issue: System boots to old kernel**

**Solution:**
```bash
# Check current default
grubby --default-kernel

# Set new kernel as default
grubby --set-default /boot/vmlinuz-5.14.21

# Reboot
reboot
```

---

### Step 2: NVIDIA Driver 470 & CUDA 11.4 Installation

**Prerequisites:**
- Rocky Linux 9 system running custom kernel 5.14.x (from Step 1)
- Root privileges
- Internet connectivity

**Steps:**

1. **Update the system:**
   ```bash
   dnf -y update
   ```

2. **Install EPEL Repository:**
   ```bash
   dnf -y install epel-release
   ```

3. **Add NVIDIA CUDA Repository:**
   ```bash
   dnf -y config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
   ```

4. **Install NVIDIA Driver (Version 470):**
   ```bash
   dnf -y module install nvidia-driver:470-dkms
   ```

   > **Note**: If the module install fails, you may need to install directly:
   > ```bash
   > dnf -y install nvidia-driver-470 nvidia-driver-470-dkms
   > ```

5. **Install CUDA Toolkit 11.4:**
   ```bash
   dnf -y install cuda-11-4
   ```

6. **Set up CUDA Environment Variables:**
   ```bash
   # Create /etc/profile.d/cuda-11.4.sh
   cat > /etc/profile.d/cuda-11.4.sh << 'EOF'
#!/bin/sh
# cuda-11.4.sh - CUDA 11.4 environment configuration for Tesla K80 support
export PATH=/usr/local/cuda-11.4/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-11.4/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
EOF

   # Apply changes
   source /etc/profile.d/cuda-11.4.sh
   ```

7. **Reboot to load NVIDIA driver:**
   ```bash
   reboot
   ```

**Verification:**
```bash
# Check CUDA compiler
nvcc --version
# Should show: Cuda compilation tools, release 11.4

# Check driver and GPU
nvidia-smi
# Should show Tesla K80 GPU(s) with driver version 470.x
```

---

### Step 3: CMake 4.0 Installation

1. **Install OpenSSL Development Libraries:**
   ```bash
   dnf -y install openssl-devel
   ```

2. **Download CMake Source Code:**
   ```bash
   cd /usr/local/src
   wget https://github.com/Kitware/CMake/releases/download/v4.0.0/cmake-4.0.0.tar.gz
   ```

3. **Extract the Archive:**
   ```bash
   tar xvf cmake-4.0.0.tar.gz
   ```

4. **Create Installation Directory:**
   ```bash
   mkdir /usr/local/cmake-4
   ```

5. **Configure CMake:**
   ```bash
   cd /usr/local/cmake-4
   /usr/local/src/cmake-4.0.0/configure
   ```

6. **Compile CMake:**
   ```bash
   make -j $(nproc)
   ```

7. **Install CMake:**
   ```bash
   make install
   ```

8. **Verify Installation:**
   ```bash
   cmake --version
   # Should output: cmake version 4.0.0
   ```

---

### Step 4: Go 1.24.2 Installation

1. **Download Go Distribution:**
   ```bash
   cd /usr/local
   wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
   ```

2. **Extract the Archive:**
   ```bash
   tar xvf go1.24.2.linux-amd64.tar.gz
   ```

3. **Post Install Configuration:**
   ```bash
   cat > /etc/profile.d/go-1.24.2.sh << 'EOF'
#!/bin/sh
# go-1.24.2.sh - Go 1.24.2 environment configuration
export PATH=/usr/local/go/bin${PATH:+:${PATH}}
EOF

   source /etc/profile.d/go-1.24.2.sh
   ```

4. **Verify Installation:**
   ```bash
   go version
   # Should output: go version go1.24.2 linux/amd64
   ```

---

### Step 5: GCC 10 Installation (Optional - For Source Compilation Only)

#### When Do You Need GCC 10?

**✅ Required if:**
- You want to compile ollama37 from source
- You're building custom CUDA kernels
- You're modifying C++ components

**❌ Not needed if:**
- You're only running pre-built ollama37 binaries
- You're using Docker images
- You only need to run models (not compile code)

#### Why GCC 10 Specifically?

- **CUDA 11.4 nvcc** is not compatible with GCC 11.5+
- **Rocky Linux 9** ships with GCC 11.5 by default
- GCC 11.5 is sufficient for running ollama37, but **not for compiling** it
- GCC 10 is the last version fully compatible with CUDA 11.4

#### Installation Steps

**Complete installation script:**
```bash
# Install prerequisites
dnf -y install wget unzip lbzip2
dnf -y groupinstall "Development Tools"

# Download and extract GCC 10 source
cd /usr/local/src
wget https://github.com/gcc-mirror/gcc/archive/refs/heads/releases/gcc-10.zip
unzip gcc-10.zip
cd gcc-releases-gcc-10

# Download GCC prerequisites (GMP, MPFR, MPC, ISL)
contrib/download_prerequisites

# Create build directory and configure
mkdir /usr/local/gcc-10
cd /usr/local/gcc-10
/usr/local/src/gcc-releases-gcc-10/configure --disable-multilib

# Compile and install (1-2 hours depending on CPU)
make -j $(nproc)
make install
```

> **Note**: The compilation step `make -j $(nproc)` will take 1-2 hours depending on your CPU performance. The `$(nproc)` command uses all available CPU cores to speed up compilation.

**Post-Install Configuration:**
```bash
# Create environment script for library paths
cat > /etc/profile.d/gcc-10.sh << 'EOF'
#!/bin/sh
# gcc-10.sh - GCC 10 library path configuration
export LD_LIBRARY_PATH=/usr/local/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
EOF

# Configure dynamic linker
echo "/usr/local/lib64" > /etc/ld.so.conf.d/gcc-10.conf
ldconfig
```

**Verify Installation:**
```bash
/usr/local/bin/gcc --version
# Should output: gcc (GCC) 10.x.x

/usr/local/bin/g++ --version
# Should output: g++ (GCC) 10.x.x
```

---

### Step 6: Ollama37 Compilation (Optional - For Custom Builds)

**Prerequisites:**
All components installed as per the guides above:
- Rocky Linux 9 with custom kernel 5.14.x
- Git
- CMake 4.0
- Go 1.24.2
- **GCC 10** (required for source compilation)
- CUDA Toolkit 11.4

**Compilation Steps:**

1. **Navigate to Build Directory:**
   ```bash
   cd /usr/local/src
   ```

2. **Clone the Repository:**
   ```bash
   git clone https://github.com/dogkeeper886/ollama37
   cd ollama37
   ```

3. **CMake Configuration:**
   Set compiler variables and configure the build system:
   ```bash
   cmake -B build
   ```

4. **CMake Build:**
   Compile the C++ components (parallel build):
   ```bash
   cmake --build build -j$(nproc)
   ```

   > **Note:** `-j$(nproc)` enables parallel compilation using all available CPU cores. You can specify a number like `-j4` to limit the number of parallel jobs.

5. **Go Build:**
   Compile the Go components:
   ```bash
   go build -o ollama .
   ```

6. **Verification:**
   ```bash
   ./ollama --version
   ```

7. **Optional: Install System-Wide:**
   ```bash
   cp ollama /usr/local/bin/
   cp -r lib/ollama /usr/local/lib/
   ```

---

## Tesla K80 Specific Optimizations

The Ollama37 build includes several Tesla K80-specific optimizations:

### CUDA Architecture Support
- **CMake Configuration**: `CMAKE_CUDA_ARCHITECTURES "37;50;61;70;75;80"`
- **Build Files**: Located in `ml/backend/ggml/ggml/src/ggml-cuda/CMakeLists.txt`

### CUDA 11 Compatibility
- Uses CUDA 11 toolchain (CUDA 12 dropped Compute Capability 3.7 support)
- Environment variables configured for CUDA 11.4 paths
- Driver version 470 for maximum compatibility

### Performance Tuning
- Optimized memory management for Tesla K80's 12GB VRAM
- Kernel optimizations for Kepler architecture
- Reduced precision operations where appropriate
- Enhanced VMM pool with granularity alignment
- Progressive memory allocation fallback (4GB → 2GB → 1GB → 512MB)

---

## Troubleshooting

### NVIDIA Driver Issues

**Issue: nvidia-smi shows "Failed to initialize NVML"**

**Solution:**
```bash
# Check if driver is loaded
lsmod | grep nvidia

# If not loaded, load manually
modprobe nvidia

# Check dmesg for errors
dmesg | grep -i nvidia
```

---

**Issue: Driver loads but CUDA version mismatch**

**Solution:**
```bash
# Check CUDA version
nvcc --version

# Check driver CUDA support
nvidia-smi

# Ensure PATH points to CUDA 11.4
echo $PATH | grep cuda-11.4
```

---

### CUDA Compilation Issues

**Issue: nvcc not found**

**Solution:**
```bash
# Check if CUDA is in PATH
which nvcc

# If not, source environment
source /etc/profile.d/cuda-11.4.sh

# Verify
nvcc --version
```

---

**Issue: "nvcc fatal: Unsupported gpu architecture 'compute_37'"**

**Solution:**
This error means you're using CUDA 12 instead of CUDA 11.4. Ensure:
```bash
# Check CUDA version
nvcc --version
# Must show CUDA 11.4

# If wrong version, check PATH
echo $PATH
# Should include /usr/local/cuda-11.4/bin BEFORE any other CUDA paths
```

---

### GCC Version Issues

**Issue: CMake can't find GCC 10**

**Solution:**
```bash
# Check GCC version
/usr/local/bin/gcc --version
# Should show GCC 10.x

# If build fails, explicitly set CC and CXX
export CC=/usr/local/bin/gcc
export CXX=/usr/local/bin/g++
```

---

**Issue: CUDA compilation fails with GCC 11 errors**

**Solution:**
```bash
# CUDA 11.4 is not compatible with GCC 11+
# You MUST use GCC 10 for compilation
# Ensure you've installed GCC 10 (Step 5)

# Verify compiler paths
which gcc  # Should point to /usr/local/bin/gcc
/usr/local/bin/gcc --version  # Should show 10.x
```

---

### Memory Issues

**Issue: Out of memory during model loading**

**Solution:**
- Tesla K80 has 12GB VRAM per GPU
- Use quantized models (Q4_0, Q8_0) for better memory efficiency
- Reduce context length: `ollama run model --num-ctx 2048`
- Monitor GPU memory: `watch -n 1 nvidia-smi`

---

### Build Verification

After successful compilation, verify Tesla K80 support:

```bash
# Check if ollama detects your GPU
./ollama serve &

# Pull a small model
./ollama pull llama3.2:3b

# Test inference
./ollama run llama3.2:3b "Hello Tesla K80!"

# Monitor GPU utilization
watch -n 1 nvidia-smi
```

---

## Performance Optimization Tips

1. **Model Selection**: Use quantized models (Q4_0, Q8_0) for better performance on Tesla K80
2. **Memory Management**: Monitor VRAM usage and adjust context sizes accordingly
3. **Temperature Control**: Ensure adequate cooling for sustained workloads
4. **Power Management**: Tesla K80 requires proper power delivery (225W per GPU)
5. **Multi-GPU**: For dual K80 setups, use `CUDA_VISIBLE_DEVICES=0,1` to leverage both GPUs

---

## Summary: Installation Paths

### Path 1: Pre-built Binary (Easier)
1. Compile custom kernel 5.14.x
2. Install NVIDIA Driver 470 & CUDA 11.4
3. Install CMake 4.0
4. Install Go 1.24.2
5. Download pre-built ollama37 binary
6. ❌ Skip GCC 10 installation (not needed)

### Path 2: Compile from Source (Advanced)
1. Compile custom kernel 5.14.x
2. Install NVIDIA Driver 470 & CUDA 11.4
3. Install CMake 4.0
4. Install Go 1.24.2
5. ✅ **Install GCC 10** (required for compilation)
6. Compile ollama37 from source

Choose the path that best fits your requirements and technical expertise.
