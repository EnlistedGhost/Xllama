# CI/CD Pipeline for Ollama37

## Project Goal

Enable Ollama to run on Tesla K80 GPUs (CUDA compute capability 3.7), which are no longer supported by mainstream Ollama builds. This requires custom compilation with CUDA 11.4 and legacy CUBLAS function fallbacks.

## Infrastructure

The CI/CD pipeline runs on a self-hosted GitHub Actions runner with Tesla K80 hardware. This is necessary because:

1. K80 requires specific NVIDIA driver (470.x) and CUDA version (11.4)
2. Cloud runners don't provide legacy GPU hardware
3. Real GPU testing is essential - emulation cannot catch CUBLAS compatibility issues

## Build Strategy

The build uses a two-stage Docker approach:

**Stage 1 (Builder)**: A cached base image containing the complete toolchain - Rocky Linux 8, CUDA 11.4, GCC 10 (compiled from source due to RHEL limitations), CMake, and Go. This image takes ~90 minutes to build but is reused across all builds.

**Stage 2 (Runtime)**: Built on each commit, this stage clones the source, compiles with K80-specific CMake presets, and packages the binary. Build time is ~10 minutes.

This separation means routine builds are fast while toolchain changes are rare and cached.

## Test Framework Design

### Philosophy

The test framework is designed around two key insights:

1. **Exit codes lie**: A CUDA operation can fail silently, returning success while producing garbage output. Traditional pass/fail based on exit codes misses these failures.

2. **Logs tell truth**: The real story is in the execution logs - CUBLAS errors, memory allocation failures, and GPU fallback warnings appear there even when commands "succeed".

### Judge System

The framework implements a dual-judge architecture:

**Simple Judge**: Fast, deterministic verification based on exit codes. Catches obvious failures like command not found, timeout, or explicit error exits.

**LLM Judge**: Semantic analysis of test execution logs using a language model. The judge receives test criteria and logs, then evaluates whether the actual behavior matches expected behavior. This catches:
- CUDA errors that don't cause exit failures
- Subtle GPU fallback to CPU mode
- Memory allocation warnings
- Incorrect but non-crashing output

**Dual Mode** (default): Both judges must pass. This combines the speed of simple checking with the depth of semantic analysis.

### Log Collection

A critical problem with container log analysis is temporal precision. Using `docker compose logs --since=5m` creates issues:

- Logs from previous tests contaminate current test analysis
- Long-running tests may exceed the time window
- Fast tests include irrelevant historical logs

The LogCollector solves this by running `docker compose logs --follow` as a background process throughout test execution. It maintains markers for each test's start and end, then extracts precisely the logs generated during that specific test. Each test step receives only its own logs for analysis.

### Test Execution Flow

1. **Load Phase**: YAML test definitions are parsed and sorted by dependency order
2. **Collection Start**: LogCollector begins streaming container logs
3. **Execution Phase**: Tests run sequentially, each step receiving current test ID via environment
4. **Log Capture**: Before each step, accumulated logs are written to a test-specific file
5. **Judgment Phase**: Both judges evaluate results - simple checks exit codes, LLM analyzes logs
6. **Cleanup**: Models are unloaded from VRAM, log collector stops

### Test Architecture

Tests are organized into three suites that must run in order:

**Build Suite**: Verifies Docker images exist and are correctly configured. No GPU required.

**Runtime Suite**: Starts the container and verifies GPU detection. Checks that Ollama recognizes K80 hardware and loads CUDA libraries. Critical validation that the driver/toolkit/container integration works.

**Inference Suite**: Actually runs models of increasing size. The 4B model tests basic functionality, 12B tests single-GPU capacity, and 27B tests multi-GPU layer splitting. Each model size unloads after testing to free VRAM for the next.

### Model Unload Strategy

K80 has limited VRAM (12GB per GPU). The framework explicitly unloads each model after its tests complete, rather than relying on automatic eviction. This ensures:

- Predictable VRAM state between tests
- No interference from cached models
- Clean baseline for each model size test

Workflow-level cleanup provides a safety net if individual test unloads fail.

## Error Detection

The framework specifically watches for K80-related failure patterns:

- `CUBLAS_STATUS_*` errors indicate the legacy CUBLAS fallback isn't working
- `CUDA error` messages suggest driver/toolkit mismatch
- `cudaMalloc failed` indicates VRAM exhaustion
- `id=cpu library=cpu` means GPU detection failed entirely

These patterns are checked by both the simple judge (via grep in test steps) and the LLM judge (via semantic log analysis).

## Design Decisions

**Why YAML test cases?** Declarative test definitions separate test logic from execution machinery. Adding a new test requires no code changes.

**Why LLM judging?** Traditional test assertions require anticipating every failure mode. LLM evaluation can recognize novel failures and evaluate fuzzy criteria like "response should mention Paris".

**Why sequential execution?** Log collection with precise boundaries requires knowing which test is running. Parallel execution would interleave logs unpredictably.

**Why Docker-based builds?** Reproducibility. The exact toolchain that works is captured in the builder image. No "works on my machine" issues.

**Why self-hosted runners?** K80 hardware. No cloud provider offers compute capability 3.7 GPUs for CI/CD.

## Limitations

- Tests must run sequentially for accurate log collection
- LLM judge requires a working Ollama instance (chicken-and-egg for broken builds)
- K80 VRAM limits restrict maximum model size to ~27B parameters
- Build times are significant due to CUDA compilation
