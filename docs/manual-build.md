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
1. **Install GCC 10** - Required for kernel compilation and ollama37 source builds
2. **Compile Custom Kernel** (Linux 5.14.x) - Required for NVIDIA 470 compatibility
3. **Install NVIDIA Driver 470** - Tesla K80 GPU driver support
4. **Install CUDA 11.4 Toolkit** - CUDA development environment
5. **Install CMake 4.0** - Build system
6. **Install Go 1.25.3** - Go compiler
7. **Compile Ollama37** (Optional - if not using pre-built binaries)

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

### Step 1: GCC 10 Installation

**Why Install GCC 10 First?**

GCC 10 is required for:
- Compiling the custom Linux kernel (Step 2)
- Building ollama37 from source (Step 7)
- CUDA 11.4 compatibility (CUDA 11.4 nvcc is not compatible with GCC 11.5+)

Rocky Linux 9 ships with GCC 11.5 by default, which is:
- ❌ **Incompatible** with CUDA 11.4 nvcc compiler
- ❌ **Not recommended** for kernel compilation with NVIDIA drivers
- ✅ **Sufficient** for running pre-built binaries (if you skip Steps 2 and 7)

**Prerequisites:**
- Rocky Linux 9
- Root privileges
- Internet connectivity

**Steps:**

1. **Complete installation script:**
    ```bash
    # Install prerequisites
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

2. **Post-Install Configuration:**
   ```bash
    # Configure dynamic linker to include both system and GCC 10 library paths
    cat > /etc/ld.so.conf.d/gcc-10.conf << 'EOF'
    /usr/lib64
    /usr/local/lib64
    EOF

    ldconfig

    # Update system compiler symlinks to use GCC 10
    rm -f /usr/bin/cc
    ln -s /usr/local/bin/gcc /usr/bin/cc
   ```

### Verification:
```bash
# Verify GCC 10 installation
gcc --version
# Should output: gcc (GCC) 10.x.x

g++ --version
# Should output: g++ (GCC) 10.x.x

# Verify symlinks are correct
which cc
# Should output: /usr/bin/cc

ls -al /usr/bin/cc
# Should show: /usr/bin/cc -> /usr/local/bin/gcc
```

---

### Step 2: Kernel Compilation (Required for NVIDIA 470 Compatibility)

**Why Compile a Custom Kernel?**

Recent kernel updates in Rocky Linux 9, Fedora, and Ubuntu have broken compatibility with:
- NVIDIA Driver 470 (required for Tesla K80 / Compute Capability 3.7)
- CUDA 11.4 nvcc compiler

Solution: Use Linux kernel 5.14.x, which maintains stable NVIDIA 470 driver support.

**Prerequisites:**
- Rocky Linux 9 (clean installation recommended)
- Root privileges
- At least 20GB free disk space
- Stable internet connection

**Steps:**

1. **Install build tools:**
   ```bash
   dnf -y groupinstall "Development Tools"
   dnf -y install ncurses-devel
   ```

2. **Navigate to source directory:**
   ```bash
   cd /usr/src/kernels
   ```

3. **Download Linux 5.14.x kernel:**
   ```bash
   wget https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.14.tar.xz
   ```

   > **Note**: Check [kernel.org](https://www.kernel.org/pub/linux/kernel/v5.x/) for the latest 5.14.x stable release.

4. **Extract the archive:**
   ```bash
   tar xvf linux-5.14.tar.xz
   cd linux-5.14
   ```

5. **Copy existing kernel configuration:**
   ```bash
   # Copy config from the running kernel
   cp /usr/src/kernels/$(uname -r)/.config .config
   ```

   > **Note**: If you need to check available kernel configurations first: `ls /usr/src/kernels`

6. **Open menuconfig to adjust settings:**
   ```bash
   make menuconfig
   ```

7. **Required Configuration Changes:**

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

8. **Save configuration:**
   - Press `<Save>`
   - Confirm default filename `.config`
   - Press `<Exit>` to quit menuconfig

9. **Compile kernel (using all CPU cores):**
   ```bash
   make -j$(nproc)
   ```

   > **Estimated time**: 30-60 minutes depending on CPU performance

10. **Install kernel modules:**
    ```bash
    make modules_install
    ```

11. **Install kernel:**
    ```bash
    make install
    ```

12. **Reboot system:**
    ```bash
    reboot
    ```

### Verification:
```bash
# After reboot, verify kernel version
uname -r
# Should output: 5.14.21
```

### Troubleshooting:

#### Issue: BTF-related build errors
```
BTF: .tmp_vmlinux.btf: pahole (pahole) is not available
Failed to generate BTF for vmlinux
```

**Solution:**
- Disable `CONFIG_DEBUG_INFO_BTF` in menuconfig (see step 7c above)

#### Issue: Module signing key errors
```
Can't read private key
```

**Solution:**
- Disable `CONFIG_MODULE_SIG_ALL` and clear `CONFIG_SYSTEM_TRUSTED_KEYS` in menuconfig
- Ensure the "System trusted keys filename" field is completely empty

---

### Step 3: NVIDIA Driver 470 Installation

**Prerequisites:**
- Rocky Linux 9 system running custom kernel 5.14.x (from Step 2)
- Root privileges
- Internet connectivity

**Steps:**

1. **Update the system:**
   ```bash
   dnf -y update
   ```

2. **Install required dependencies:**
   ```bash
   dnf -y install epel-release
   dnf -y install libglvnd-devel.x86_64
   ```

3. **Switch to text mode (runlevel 3):**
   ```bash
   init 3
   ```

   > **Note**: This will exit the graphical interface. You'll need to log in via text console.

4. **Download NVIDIA Driver 470.256.02:**
   ```bash
   cd /tmp
   wget https://us.download.nvidia.com/tesla/470.256.02/NVIDIA-Linux-x86_64-470.256.02.run
   ```

5. **Install NVIDIA Driver:**
   ```bash
   chmod +x NVIDIA-Linux-x86_64-470.256.02.run
   sh NVIDIA-Linux-x86_64-470.256.02.run
   ```

   > **Installation prompts:**
   > - Accept the license agreement
   > - If asked about DKMS, select "Yes" to register with DKMS
   > - If asked about 32-bit compatibility libraries, select based on your needs
   > - If asked about X configuration, select "Yes" if you use graphical interface

6. **Reboot to load NVIDIA driver:**
   ```bash
   reboot
   ```

### Verification:
```bash
# Check driver and GPU
nvidia-smi
# Should show Tesla K80 GPU(s) with driver version 470.256.02
```

---

### Step 4: CUDA 11.4 Toolkit Installation

**Prerequisites:**
- NVIDIA Driver 470 installed and verified (from Step 3)
- Root privileges

**Steps:**

1. **Download CUDA 11.4.0 installer:**
   ```bash
   cd /tmp
   wget https://developer.download.nvidia.com/compute/cuda/11.4.0/local_installers/cuda_11.4.0_470.42.01_linux.run
   ```

2. **Run CUDA installer:**
   ```bash
   sh cuda_11.4.0_470.42.01_linux.run
   ```

   > **Installation prompts:**
   > - Accept the license agreement
   > - **IMPORTANT**: Deselect "Driver" option (driver already installed in Step 3)
   > - Keep selected: CUDA Toolkit, CUDA Samples, CUDA Demo Suite, CUDA Documentation
   > - Confirm installation

3. **Set up CUDA Environment Variables:**

   Create two configuration files:

   **a) PATH configuration in `/etc/profile.d/`:**
   ```bash
   cat > /etc/profile.d/cuda-11.4.sh << 'EOF'
   #!/bin/sh
   # cuda-11.4.sh - CUDA 11.4 PATH configuration for Tesla K80 support
   export PATH=/usr/local/cuda-11.4/bin${PATH:+:${PATH}}
   EOF

   # Apply PATH changes
   source /etc/profile.d/cuda-11.4.sh
   ```

   **b) Dynamic linker configuration:**

   The CUDA installer creates `/etc/ld.so.conf.d/cuda-11-4.conf` automatically with the following content:
   ```
   /usr/local/cuda-11.4/lib64
   /usr/local/cuda-11.4/targets/x86_64-linux/lib
   ```

   If the file doesn't exist or needs to be recreated:
   ```bash
   cat > /etc/ld.so.conf.d/cuda-11-4.conf << 'EOF'
   /usr/local/cuda-11.4/lib64
   /usr/local/cuda-11.4/targets/x86_64-linux/lib
   EOF

   # Update dynamic linker cache
   ldconfig
   ```

### Verification:
```bash
# Check CUDA compiler
nvcc --version
# Should show: Cuda compilation tools, release 11.4, V11.4.48

# Check driver and CUDA compatibility
nvidia-smi
# Should show Tesla K80 GPU(s) with driver version 470.256.02 and CUDA Version: 11.4
```

---

### Step 5: CMake 4.0 Installation

**Prerequisites:**
- Root privileges
- Internet connectivity

**Steps:**

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

### Verification:
```bash
cmake --version
# Should output: cmake version 4.0.0
```

---

### Step 6: Go 1.25.3 Installation

**Prerequisites:**
- Root privileges
- Internet connectivity

**Steps:**

1. **Download Go Distribution:**
   ```bash
   cd /usr/local
   wget https://go.dev/dl/go1.25.3.linux-amd64.tar.gz
   ```

2. **Extract the Archive:**
   ```bash
   tar xvf go1.25.3.linux-amd64.tar.gz
   ```

3. **Post Install Configuration:**
   ```bash
   cat > /etc/profile.d/go.conf << 'EOF'
   #!/bin/sh
   # go.conf - Go environment configuration
   export PATH=/usr/local/go/bin${PATH:+:${PATH}}
   EOF

   # Apply the configuration
   source /etc/profile.d/go.conf
   ```

### Verification:
```bash
go version
# Should output: go version go1.25.3 linux/amd64
```

---

### Step 7: Ollama37 Compilation (Optional - For Custom Builds)

**Prerequisites:**
- GCC 10 (from Step 1)
- Rocky Linux 9 with custom kernel 5.14.x (from Step 2)
- NVIDIA Driver 470 (from Step 3)
- CUDA Toolkit 11.4 (from Step 4)
- CMake 4.0 (from Step 5)
- Go 1.25.3 (from Step 6)
- Git

**Steps:**

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

### Verification:
```bash
./ollama --help
```

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

## Summary: Installation Paths

### Path 1: Pre-built Binary (Easier)
1. ❌ Skip GCC 10 installation (not needed for pre-built binaries)
2. Compile custom kernel 5.14.x
3. Install NVIDIA Driver 470
4. Install CUDA 11.4 Toolkit
5. Install CMake 4.0
6. Install Go 1.25.3
7. Download and run pre-built ollama37 binary

### Path 2: Compile from Source (Advanced - Requires All Steps)
1. ✅ **Install GCC 10** (required for kernel and ollama37 compilation)
2. Compile custom kernel 5.14.x (uses GCC 10)
3. Install NVIDIA Driver 470
4. Install CUDA 11.4 Toolkit
5. Install CMake 4.0
6. Install Go 1.25.3
7. Compile ollama37 from source (uses GCC 10)

Choose the path that best fits your requirements and technical expertise.
