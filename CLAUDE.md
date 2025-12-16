# Claude Code Development Notes

This document tracks development goals and notes for this Ollama repository fork.

## Project Goals

### 1. CUDA Compute Capability 3.7 Support (Tesla K80)
- **Objective**: Add support for CUDA compute capability 3.7 to enable running on Tesla K80 GPUs
- **Environment**:
  - GCC version: 10.5
  - CUDA version: 11.4.4
  - NVIDIA driver: 470
  - Target GPU: Tesla K80 (compute capability 3.7)
- **Status**: ✅ Complete

### 2. Code Documentation Policy
- **Issue**: This repo is cloned from official Ollama, which lacks code comments, making debugging difficult
- **Policy**: Add helpful comments when figuring out code functionality
- **Rationale**: Improve code maintainability and debugging experience

## Implementation Summary

### Files Modified
1. `ml/backend/ggml/ggml/src/ggml-cuda/CMakeLists.txt` - Added 3.7 compute capability to default architecture list
2. `CMakePresets.json` - Added compute 3.7 to "CUDA 11" preset and created dedicated "CUDA 11 K80" preset
3. `ml/backend/ggml/ggml/src/CMakeLists.txt` - Enabled Alderlake CPU variant without AVX_VNNI
4. `ml/backend/ggml/ggml/src/ggml-cuda/ggml-cuda.cu` - Added CUBLAS legacy function fallback for Kepler GPU compatibility

### Key Changes
- Added `37-virtual` to CMAKE_CUDA_ARCHITECTURES (using PTX with JIT compilation for better compatibility)
- Updated "CUDA 11" preset to include compute 3.7 alongside other supported architectures
- Created "CUDA 11 K80" preset for K80-only optimized builds
- Enabled Alderlake CPU variant without AVX_VNNI (GCC 10 limitation)
- Added `-Wno-deprecated-gpu-targets` flag to suppress warnings

### CUDA Version Compatibility
- **CUDA 11.4.4 supports**: 37, 50, 52, 60, 61, 70, 75, 80, 86
- **CUDA 11.4.4 does NOT support**: 87 (requires 11.7+), 89 (requires 11.8+), 90 (requires 12.0+)
- CUDA 12+ dropped Kepler support entirely

### Tesla K80 CUBLAS Compatibility

**Challenge**: Tesla K80 (Kepler, compute 3.7) requires special handling for batched matrix multiplication due to:
1. Lack of Tensor Cores (introduced in Volta, compute 7.0+)
2. Architectural limitations with modern CUBLAS `*Ex` function variants

**Solution - Two-Tier Fallback Strategy**:

**Tier 1: GEMM Algorithm Selection**
- Volta+ (cc >= 7.0): Use `CUBLAS_GEMM_DEFAULT_TENSOR_OP` (value 99)
- Pre-Volta (cc < 7.0): Use `CUBLAS_GEMM_DEFAULT` (value -1)

**Tier 2: CUBLAS Function Selection**
- **Modern GPUs** (Volta+): Use `cublasGemmStridedBatchedEx` / `cublasGemmBatchedEx`
  - Support mixed precision, flexible compute types, algorithm selection
- **Legacy GPUs** (Kepler/Maxwell/Pascal with FP32): Use `cublasSgemmStridedBatched` / `cublasSgemmBatched`
  - The `*Ex` variants have architectural requirements beyond algorithm selection
  - Even with `CUBLAS_GEMM_DEFAULT`, `*Ex` functions fail with `CUBLAS_STATUS_ARCH_MISMATCH`
  - Legacy functions only support FP32, but work reliably on older architectures

**Modified Function**: `ggml_cuda_mul_mat_batched_cublas_impl` in `ml/backend/ggml/ggml/src/ggml-cuda/ggml-cuda.cu:1986`

**Tested Models** (verified on Tesla K80):
- ✅ gemma3:4b
- ✅ gpt-oss
- ✅ deepseek-r1

## Build Instructions

### Complete Build from Scratch

```bash
# Clean any previous build artifacts
rm -rf build
go clean -cache

# Configure the build (For all 11.4 or k80)
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake --preset "CUDA 11"
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake --preset "CUDA 11 K80"

# Build the C/C++/CUDA libraries
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake --build build -j$(nproc)

# Build the Go binary (with version)
OLLAMA_VERSION="2.0.1"
go build -ldflags "-X github.com/ollama/ollama/version.Version=${OLLAMA_VERSION}" -o ollama .
```

## Running Ollama

### Basic Server Start

```bash
# Start the Ollama server
./ollama serve

# Check GPU detection
nvidia-smi
```

### Debug and Logging Options

**Environment Variables**:
- `OLLAMA_DEBUG=1` - Enable verbose Ollama server logging
- `GGML_CUDA_DEBUG=1` - Enable detailed CUDA/CUBLAS operation logging (batched matrix multiplication)

```bash
# Run with Ollama verbose logging only
OLLAMA_DEBUG=1 ./ollama serve

# Run with both Ollama and CUDA debug logging
OLLAMA_DEBUG=1 GGML_CUDA_DEBUG=1 ./ollama serve

# Capture all output to file
./ollama serve 2>&1 | tee /tmp/ollama_serve.log

# Capture only stderr (warnings/errors) to file
./ollama serve 2> /tmp/ollama_errors.log

# Run in background with full logging
OLLAMA_DEBUG=1 ./ollama serve 2>&1 | tee /tmp/ollama_full.log &

# Run in background with debug logging
OLLAMA_DEBUG=1 GGML_CUDA_DEBUG=1 ./ollama serve 2>&1 | tee /tmp/ollama_debug.log &

# Monitor a running background server
tail -f /tmp/ollama_full.log

# Tail recent log entries
tail -100 /tmp/ollama_full.log

# Stop all ollama processes
pkill ollama
```

**When to Use GGML_CUDA_DEBUG**:
- Debugging CUBLAS errors on Tesla K80 or other legacy GPUs
- Verifying compute capability detection
- Troubleshooting batched matrix multiplication issues
- Understanding which CUBLAS functions are being used (legacy vs Ex variants)

## CPU Architecture Compatibility

### The GCC/CUDA/Alderlake Constraint

This build faces a fundamental compatibility constraint:

**The Constraint Chain:**
1. **Tesla K80** (compute 3.7) → Last supported by **Driver 470.xx**
2. **Driver 470.256.02** → Maximum CUDA version is **CUDA 11.4**
3. **CUDA 11.4** → Maximum GCC version is **GCC 10** (enforced in `host_config.h`)
4. **AVX_VNNI** (Alderlake CPUs) → Requires **GCC 11+** for `-mavxvnni` flag

**Result:** Cannot have both K80 GPU support AND full Alderlake CPU optimization.

### Solution: Alderlake Without AVX_VNNI

**Implementation:**
- Alderlake CPU variant is **enabled** in the build
- AVX_VNNI instruction set is **excluded** (requires GCC 11+)
- Alderlake still gets: SSE4.2, AVX, F16C, AVX2, BMI2, FMA optimizations
- Code falls back to `_mm256_maddubs_epi16()` for operations that would use VNNI

**Modified file:** `ml/backend/ggml/ggml/src/CMakeLists.txt` line 338

**Performance Impact:**
- Most operations: **No impact** (still uses AVX2, FMA, BMI2)
- INT8 dot products: **~10-20% slower** than native AVX_VNNI
- Overall model inference: **~3-7% slower** (depends on quantization)

### CPU Support Matrix

| CPU Generation | Variant Used | Full Optimization | Notes |
|----------------|--------------|-------------------|-------|
| Haswell (2013) | haswell | ✅ Yes | Xeon E5-2676 v3 |
| Skylake-X (2017) | skylakex | ✅ Yes | Includes AVX512 |
| Icelake (2019) | icelake | ✅ Yes | Includes AVX512_VNNI |
| Alderlake (2021) | alderlake | ⚠️ Partial | Missing AVX_VNNI only |
| Raptor Lake (2022) | alderlake | ⚠️ Partial | Missing AVX_VNNI only |

