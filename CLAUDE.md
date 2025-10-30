# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Goal

This project (ollama37) exists to maintain support for NVIDIA Tesla K80 GPUs and other Compute Capability 3.7 hardware. The official Ollama release has deprecated support for these older GPUs, but this fork keeps them functional by:

- Maintaining sync with the official Ollama repository for latest features and fixes
- Preserving CUDA Compute Capability 3.7 support that was removed from upstream
- Providing a specialized build optimized for Tesla K80 and similar legacy hardware

This enables users with older NVIDIA GPUs to continue running modern LLMs locally without requiring hardware upgrades.

## CUDA 3.7 Support Implementation

CUDA Compute Capability 3.7 support is maintained in the following key locations:

- **`ml/backend/ggml/ggml/src/ggml-cuda/CMakeLists.txt:7`** - Core build configuration with `CMAKE_CUDA_ARCHITECTURES "37;50;61;70;75;80"`
- **`CMakePresets.json:24`** - "CUDA 11" preset includes "37" (CUDA 12 dropped 3.7 support)
- **`README.md:63-66`** - Tesla K80 support overview and technical details
- **`docs/manual-build.md`** - Comprehensive Tesla K80 build instructions and optimizations
- **`docs/gpu.md:33`** - General GPU building guidance

The project uses CUDA 11 toolchain to maintain compatibility with Tesla K80 and other Compute Capability 3.7 GPUs, as CUDA 12 officially dropped support for these architectures.

## CC 3.7-Only Optimization Strategy

**Status**: ✅ **COMPLETED** - All 9 phases complete and tested successfully

**Completion Summary**: Successfully simplified CUDA backend to support only CC 3.7 (Kepler/Tesla K80). After the initial optimization removed modern GPU architecture constants from `common.cuh`, additional fixes were required to handle undefined constant references throughout the codebase. All MMA (tensor core) functions have been properly disabled while preserving DP4A functions for CC 3.7 compatibility.

**Critical Runtime Fix - Phase 9 (2025-10-29)**: After Phase 8, CUDA backend failed to load due to undefined Flash Attention symbols. Solution implemented:
1. Disabled all flash attention helper functions with `#if 0` (lines 126-274 in fattn.cu)
2. Simplified main `ggml_cuda_flash_attn_ext()` function to abort immediately for CC 3.7
3. Added `GGML_UNUSED` macros to prevent compiler warnings
4. **Build successful** ✅
5. **Runtime testing successful** ✅ - CUDA backend loads, GPU offloading works correctly

**Verified Working**:
- ✅ CUDA backend loads without undefined symbol errors
- ✅ Log shows: `load_backend: loaded CUDA backend from libggml-cuda.so`
- ✅ Layers offload to GPU correctly (e.g., 35/35 layers for gemma3:4b)
- ✅ Fast GPU inference confirmed

**Goal**: Simplify the codebase by removing support for all CUDA Compute Capabilities except 3.7, since newer GPUs (CC 5.0+) are already supported by upstream Ollama.

### Rationale

- **Upstream Ollama**: Supports CC 5.0+ (Maxwell and newer GPUs)
- **Unique to Ollama37**: Only CC 3.7 (Kepler - Tesla K80, K40, M40)
- **Clear positioning**: "For Tesla K80 and Kepler GPUs only"
- **Benefits**:
  - 80-85% smaller binaries (compile for 1 arch instead of 6)
  - 5-6x faster build times
  - Simpler codebase (no dead code for features CC 3.7 doesn't have)
  - Easier maintenance and debugging

### Features NOT Available on CC 3.7

The following modern GPU features can be removed from the codebase:

- **FP16 native operations** (requires CC 6.0+ Pascal)
- **DP4A instruction** (int8 dot product, requires CC 6.1+)
- **Tensor Cores / MMA / WMMA** (requires CC 7.0+ Volta/Turing)
- **Async memory copy / CP_ASYNC** (requires CC 8.0+ Ampere)
- **Flash Attention** (requires CC 7.0+)
- **Stream-K scheduling** (optimized for CC 7.0+)

### ✅ Completed Optimizations

**Files completely removed** (~116KB):
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/mma.cuh` - Tensor core operations
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/fattn-wmma-f16.cu` - Flash attention with WMMA
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/fattn-wmma-f16.cuh`
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/fattn-mma-f16.cuh`
- ✅ 39 template instantiation files for MMA/WMMA operations

**Files simplified for CC 3.7 only**:
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/common.cuh` - Removed architecture detection, hardcoded CC 3.7
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/mmq.cuh` - Disabled 6 MMA functions, removed Volta+ optimizations
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/mmq.cu` - Disabled Stream-K scheduling
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/convert.cu` - Disabled Pascal+ FP16 code block
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/mmv.cu` - Hardcoded FP32 precision
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/mmvmxfp4.cu` - Hardcoded FP32 precision
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/ggml-cuda.cu` - Disabled BF16, CUDA graphs, Volta checks
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/fattn.cu` - Replaced Ada Lovelace constant references
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/fattn-common.cuh` - Simplified Stream-K scheduling

**Build configuration**:
- ✅ `ml/backend/ggml/ggml/src/ggml-cuda/CMakeLists.txt:7` - Set to `"37"` only
- ✅ `CMakePresets.json:25` - CUDA 11 preset set to `"37"` only

**Post-completion fixes** (architecture constant references):
- ✅ Fixed undefined `GGML_CUDA_CC_PASCAL`, `GGML_CUDA_CC_VOLTA`, `GGML_CUDA_CC_DP4A`, `GGML_CUDA_CC_ADA_LOVELACE` in 4 files
- ✅ Corrected overly broad MMA disabling in mmq.cuh that accidentally disabled DP4A functions
- ✅ Set all `vec_dot_mma` function pointers to `nullptr` in mmq_type_traits structs

### Implementation Tracking

Detailed cleanup instructions are maintained in folder-specific `CLAUDE.md` files:

- `ml/backend/ggml/ggml/src/ggml-cuda/CLAUDE.md` - CUDA kernel cleanup instructions
- `ml/CLAUDE.md` - Go-level GPU detection simplification
- `llm/CLAUDE.md` - Memory estimation optimization for single-GPU preference

These files contain specific line numbers, code blocks, and commands to execute the cleanup incrementally across sessions.

## 🎯 Tesla K80 Performance Optimizations

### Memory Estimation Optimization for Single-GPU Preference

**Status**: ⚠️ **OPTIMIZATIONS REVERTED** - Returned to upstream behavior for stability (2025-10-30)

**Original Goal**: Eliminate unnecessary multi-GPU splits by fixing graph memory overestimation for Tesla K80.

**Outcome**: Both Phase 1 and Phase 2 optimizations were too aggressive and caused OOM errors on multi-GPU models. Reverted to match upstream Ollama for maximum stability.

### Phase 1: Per-GPU Graph Allocation (2025-10-29) - REVERTED

**Status**: ⚠️ **REVERTED** - Caused insufficient headroom for multi-GPU models (2025-10-30)

**Original Goal**: Reduce graph allocation on secondary GPUs from full 1.3 GiB to 190 MiB.

**Original Results**: gemma3:12b split improved from 25,24 → 1,48 layers.

**Problem Discovered**: The 190 MiB optimization left insufficient buffer for runtime allocations (KV cache, execution buffers), causing OOM errors on larger multi-GPU models:
- gemma3:27b: Failed with only 400 MiB headroom on GPU1
- Memory estimate: 10.9 GiB, actual usage: 10.8 GiB → 0.4 GiB free → OOM on 6 MiB allocation

**Resolution**: Reverted to upstream Ollama behavior - allocate full graph to ALL GPUs with layers. This matches official Ollama (confirmed via code review of `upstream/main:llm/memory.go`).

### Phase 2: CC 3.7 Graph Correction Factor (2025-10-30) - DISABLED

**Status**: ⚠️ **DISABLED** - Caused multi-GPU OOM errors (2025-10-30)

**Original Problem**: Graph estimates were 15-20% higher than actual usage for CC 3.7 GPUs, causing gemma3:12b to fail single-GPU check by ~200 MiB margin.

**Original Solution**: Applied 85% reduction to graph estimates for CC 3.7 GPUs.

**New Problem Discovered**: The 85% correction was applied unconditionally to ALL models, including those requiring multi-GPU splits. This caused:
- gemma3:27b: Failed with "cudaMalloc failed: out of memory" on GPU 1 (16 MiB allocation)
- gpt-oss:20b: Failed with same error (2100 MiB allocation)
- Root cause: Allocator thought large models fit on single GPU due to reduced estimates

**Resolution** (`llm/memory.go:173-182`):
- Phase 2 correction factor **disabled** (commented out)
- Phase 1 optimization (per-GPU graph allocation) is sufficient for both single and multi-GPU scenarios
- Phase 1 correctly allocates:
  - Single GPU: Full graph on primary GPU
  - Multi-GPU: 190 MiB on secondary GPUs, full graph on primary GPU

**Impact**:
- ✅ gemma3:4b: Still runs on single GPU
- ✅ gemma3:12b: May split across GPUs (acceptable trade-off)
- ✅ gemma3:27b: Now works correctly with multi-GPU split
- ✅ gpt-oss:20b: Now works correctly with multi-GPU split

**Lesson Learned**: Aggressive memory optimizations for single-GPU scenarios must not be applied when multi-GPU splits are required. Phase 1's per-GPU allocation is the correct approach.

## Model Architecture Compatibility

### GPT-OSS Model Fix (2025-10-29)

**Issue**: The `gpt-oss` model architecture code expected fused tensor formats that didn't match the actual GGUF file structure, causing nil pointer panics.

**Root Cause**: Mismatch between code expectations and GGUF file format:
- Code expected: `attn_qkv` (fused), `ffn_gate_up_exps` (fused)
- GGUF contains: `attn_q/k/v` (separate), `ffn_gate_exps/up_exps` (separate)

**Fix Applied** (`model/models/gptoss/model.go`):
1. Updated `AttentionBlock` struct to use separate `Query`, `Key`, `Value` fields instead of fused `QKV`
2. Modified `AttentionBlock.Forward()` to compute Q/K/V projections separately
3. Updated `MLPBlock` struct to use separate `Gate` and `Up` fields instead of fused `GateUp`
4. Modified `MLPBlock.Forward()` to compute gate/up separately and removed incorrect reshape

**Result**: ✅ `gpt-oss:20b` model now loads and runs successfully on Tesla K80

## Documentation Structure

The project documentation is organized as follows:

- **`README.md`** - Concise overview, quick start, and basic usage (restructured for clarity)
- **`docs/manual-build.md`** - Comprehensive manual build instructions for Tesla K80 optimization
- **`docs/gpu.md`** - General GPU support and configuration
- **`docs/api.md`** - Complete REST API reference
- **`docs/development.md`** - Development setup and contribution guidelines
- **`CLAUDE.md`** - This file, providing AI assistant guidance for the codebase

## Development Commands

### Building the Project

```bash
# Configure with GCC 10 and CUDA 11.4 support
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake -B build
CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ cmake --build build

# Build Go binary
go build -o ollama .
```

For complete Tesla K80 build instructions including prerequisite installation, see `docs/manual-build.md`.

### Running Ollama
```bash
# Run development server
go run . serve

# Start server with built binary
./ollama serve
```

### Testing
```bash
# Run all tests
go test ./...

# Run tests with synctest (for Go 1.24 compatibility)
GOEXPERIMENT=synctest go test ./...

# Run integration tests (requires server running)
go test ./integration/...

# Run specific test package
go test ./server/...
```

## Architecture Overview

Ollama is a local LLM server with Go backend and C++/CUDA acceleration:

### Core Components

**Entry Point**: `main.go` uses Cobra CLI framework, delegating to `cmd/` package for command handling.

**Server Layer** (`server/`): HTTP server built on Gin framework handling:
- REST API endpoints (`routes.go`)
- Model management (download, create, delete)
- Chat and generation endpoints
- Model scheduling and GPU resource management (`sched.go`)

**LLM Integration** (`llm/`): Abstracts language model backends with platform-specific implementations:
- `server.go` - LLM server process management
- `memory.go` - GPU memory management
- Platform-specific files for Darwin, Linux, Windows

**Model Layer** (`model/`): Handles model format conversion and tokenization:
- `models/` - Model-specific implementations (Llama, Gemma3n, etc.)
- `imageproc/` - Image processing for multimodal models
- Tokenizer implementations (BPE, SentencePiece)

**ML Backend** (`ml/backend/ggml/`): C++ acceleration layer built on GGML:
- CPU optimizations with SIMD
- CUDA GPU acceleration
- ROCm/HIP support for AMD GPUs
- Memory-mapped model loading

**Conversion Pipeline** (`convert/`): Converts models from HuggingFace/PyTorch formats to GGUF:
- Architecture-specific converters for different model families
- Safetensors and PyTorch tensor reading
- Quantization support

### Key Data Flow

1. **Model Loading**: Models downloaded/converted to GGUF format, stored locally
2. **Request Processing**: HTTP requests parsed, routed through server layer
3. **Model Scheduling**: GPU resources allocated, models loaded into memory
4. **Inference**: Requests forwarded to appropriate LLM backend process
5. **Response Streaming**: Generated tokens streamed back via HTTP

### GPU Acceleration

The project supports multiple acceleration backends:
- **CUDA**: NVIDIA GPU support via `ml/backend/ggml/ggml/src/ggml-cuda/`
- **Metal**: Apple Silicon native support
- **ROCm/HIP**: AMD GPU support
- **CPU**: Optimized CPU kernels with AVX/NEON

Libraries are dynamically loaded from:
- `./lib/ollama` (Windows)
- `../lib/ollama` (Linux)
- `.` (macOS)
- `build/lib/ollama` (development)

### Configuration

- Environment variables prefixed with `OLLAMA_` (`envconfig/`)
- Model templates in `template/` directory
- Tool definitions in `tools/` for function calling

### Testing Structure

- Unit tests throughout codebase (`*_test.go`)
- Integration tests in `integration/` requiring running server
- Benchmark tests for performance validation
- Platform-specific test files for GPU/hardware features
