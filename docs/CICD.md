# CI/CD Pipeline for Ollama37

This document describes the CI/CD pipeline for building and testing Ollama37 with Tesla K80 (CUDA compute capability 3.7) support.

## Infrastructure Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              GITHUB                                      │
│                     dogkeeper886/ollama37                                │
│                                                                         │
│  Push to main ──────────────────────────────────────────────────────┐   │
└─────────────────────────────────────────────────────────────────────│───┘
                                                                      │
                                                                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CI/CD NODE                                       │
│                                                                         │
│  Hardware:                                                              │
│    - Tesla K80 GPU (compute capability 3.7)                            │
│    - NVIDIA Driver 470.x                                               │
│                                                                         │
│  Software:                                                              │
│    - Rocky Linux 9.7                                                   │
│    - Docker 29.1.3 + Docker Compose 5.0.0                              │
│    - NVIDIA Container Toolkit                                          │
│    - GitHub Actions Runner (self-hosted)                               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Test Framework

### Test Runner CLI

The test runner is located in `tests/src/` and provides a CLI tool:

```bash
cd tests
npm run dev -- run [options]
```

**Commands:**
- `run` - Execute test cases
- `list` - List all available test cases

**Options:**
| Option | Default | Description |
|--------|---------|-------------|
| `-s, --suite <suite>` | all | Filter by suite (build, runtime, inference) |
| `-i, --id <id>` | - | Run specific test by ID |
| `-w, --workers <n>` | 1 | Parallel worker count |
| `-d, --dry-run` | false | Preview without executing |
| `-o, --output <format>` | console | Output format: console, json, junit |
| `--no-llm` | false | Skip LLM, use simple exit code check only |
| `--judge-model <model>` | gemma3:12b | Model for LLM judging |
| `--dual-judge` | true | Run both simple and LLM judge |
| `--ollama-url <url>` | localhost:11434 | Test subject server |
| `--judge-url <url>` | localhost:11435 | Separate judge instance |

### Judge Modes

The test framework supports three judge modes:

| Mode | Flag | Description |
|------|------|-------------|
| **Simple** | `--no-llm` | Exit code checking only (exit 0 = pass) |
| **LLM** | `--judge-model` | Semantic analysis of test logs using LLM |
| **Dual** | `--dual-judge` | Both must pass (default) |

**LLM Judge:**
- Analyzes test execution logs semantically
- Detects hidden issues (e.g., CUDA errors with exit 0)
- Uses configurable model (default: gemma3:12b)
- Batches tests for efficient judging

**Simple Judge:**
- Fast, deterministic
- Checks exit codes only
- Fallback when LLM unavailable

### Log Collector

The test framework includes a log collector that solves log overlap issues:

**Problem:** `docker compose logs --since=5m` can include logs from previous tests or miss logs if a test exceeds 5 minutes.

**Solution:** LogCollector class that:
1. Runs `docker compose logs --follow` as background process
2. Marks test start/end boundaries
3. Writes test-specific logs to `/tmp/test-{testId}-logs.txt`
4. Provides precise logs for each test

Test steps access logs via:
```bash
LOGS=$(cat /tmp/test-${TEST_ID}-logs.txt)
```

## GitHub Workflows

Located in `.github/workflows/`:

| Workflow | Purpose |
|----------|---------|
| `build.yml` | Docker image build verification |
| `runtime.yml` | Container startup and GPU detection |
| `inference.yml` | Model inference tests (4b, 12b, 27b) |
| `full-pipeline.yml` | Orchestrates all stages sequentially |

### Workflow Inputs

| Parameter | Default | Options | Description |
|-----------|---------|---------|-------------|
| `judge_mode` | dual | simple, llm, dual | Judge strategy |
| `judge_model` | gemma3:12b | Any model | LLM for evaluation |
| `use_existing_container` | false | true, false | Reuse running container |
| `keep_container` | false | true, false | Leave container running |

### Example: Run Inference Tests

```bash
# Manual trigger via GitHub Actions UI
# Or via gh CLI:
gh workflow run inference.yml \
  -f judge_mode=dual \
  -f judge_model=gemma3:12b
```

## Test Suites

### Build Suite (3 tests)

| ID | Name | Timeout | Description |
|----|------|---------|-------------|
| TC-BUILD-001 | Builder Image Verification | 2m | Verify builder image exists |
| TC-BUILD-002 | Runtime Image Build | 30m | Build runtime image |
| TC-BUILD-003 | Image Size Validation | 30s | Check image sizes |

### Runtime Suite (3 tests)

| ID | Name | Timeout | Description |
|----|------|---------|-------------|
| TC-RUNTIME-001 | Container Startup | 2m | Start container with GPU |
| TC-RUNTIME-002 | GPU Detection | 2m | Verify K80 detected |
| TC-RUNTIME-003 | Health Check | 3m | API health verification |

### Inference Suite (5 tests)

| ID | Name | Model | Timeout | Description |
|----|------|-------|---------|-------------|
| TC-INFERENCE-001 | Model Pull | gemma3:4b | 10m | Pull and warmup 4b model |
| TC-INFERENCE-002 | Basic Inference | gemma3:4b | 3m | Simple prompt test |
| TC-INFERENCE-003 | API Endpoint Test | gemma3:4b | 2m | REST API verification |
| TC-INFERENCE-004 | Medium Model | gemma3:12b | 10m | 12b inference (single GPU) |
| TC-INFERENCE-005 | Large Model Dual-GPU | gemma3:27b | 15m | 27b inference (dual GPU) |

### Model Unload Strategy

Each model size test unloads its model after completion:

```
4b tests (001-003) → unload 4b
12b test (004) → unload 12b
27b test (005) → unload 27b
```

Workflow-level cleanup (`if: always()`) provides safety fallback.

## Test Case Structure

Test cases are YAML files in `tests/testcases/{suite}/`:

```yaml
id: TC-INFERENCE-002
name: Basic Inference
suite: inference
priority: 2
timeout: 180000

dependencies:
  - TC-INFERENCE-001

steps:
  - name: Run simple math question
    command: docker exec ollama37 ollama run gemma3:4b "What is 2+2?"
    timeout: 120000

  - name: Check for errors in logs
    command: |
      if [ -f "/tmp/test-${TEST_ID}-logs.txt" ]; then
        LOGS=$(cat /tmp/test-${TEST_ID}-logs.txt)
      else
        LOGS=$(cd docker && docker compose logs --since=5m 2>&1)
      fi
      # Check for CUDA errors...

criteria: |
  Expected:
  - Model responds with "4" or equivalent
  - NO CUBLAS_STATUS_ errors
  - NO CUDA errors
```

## Build System

### Docker Images

**Builder Image:** `ollama37-builder:latest` (~15GB)
- Rocky Linux 8
- CUDA 11.4 toolkit
- GCC 10, CMake 4.0, Go 1.25.3
- Build time: ~90 minutes (cached)

**Runtime Image:** `ollama37:latest` (~18GB)
- Built from GitHub source
- Build time: ~10 minutes

### Build Commands

```bash
cd docker

# Build base image (first time only)
make build-builder

# Build runtime from GitHub
make build-runtime

# Build without cache
make build-runtime-no-cache

# Build from local source
make build-runtime-local
```

## Running Tests Locally

### Prerequisites

1. Docker with NVIDIA runtime
2. Node.js 20+
3. Tesla K80 GPU (or compatible)

### Quick Start

```bash
# Start the container
cd docker && docker compose up -d

# Install test runner
cd tests && npm ci

# Run all tests with dual judge
npm run dev -- run --dual-judge

# Run specific suite
npm run dev -- run --suite inference

# Run single test
npm run dev -- run --id TC-INFERENCE-002

# Simple mode (no LLM)
npm run dev -- run --no-llm

# JSON output
npm run dev -- run -o json > results.json
```

### Test Output

Results are saved to `/tmp/`:
- `/tmp/build-results.json`
- `/tmp/runtime-results.json`
- `/tmp/inference-results.json`

JSON structure:
```json
{
  "summary": {
    "total": 5,
    "passed": 5,
    "failed": 0,
    "timestamp": "2025-12-17T...",
    "simple": { "passed": 5, "failed": 0 },
    "llm": { "passed": 5, "failed": 0 }
  },
  "results": [...]
}
```

## Environment Variables

### Build Environment

| Variable | Value | Description |
|----------|-------|-------------|
| `BUILDER_IMAGE` | ollama37-builder | Builder image name |
| `RUNTIME_IMAGE` | ollama37 | Runtime image name |

### Runtime Environment

| Variable | Value | Description |
|----------|-------|-------------|
| `OLLAMA_HOST` | 0.0.0.0:11434 | Server listen address |
| `NVIDIA_VISIBLE_DEVICES` | all | GPU visibility |
| `OLLAMA_DEBUG` | 1 (optional) | Enable debug logging |
| `GGML_CUDA_DEBUG` | 1 (optional) | Enable CUDA debug |

### Test Environment

| Variable | Description |
|----------|-------------|
| `TEST_ID` | Current test ID (set by executor) |
| `OLLAMA_HOST` | Test subject URL |

## Troubleshooting

### GPU Not Detected in Container

```bash
# Check UVM device files
ls -l /dev/nvidia-uvm*

# Create if missing
nvidia-modprobe -u -c=0

# Restart container
docker compose restart
```

### LLM Judge Timeout

```bash
# Use simple mode
npm run dev -- run --no-llm

# Or increase judge model size
npm run dev -- run --judge-model gemma3:4b
```

### Log Collector Issues

If test step can't find logs:
```bash
# Check log file exists
ls -l /tmp/test-*-logs.txt

# Fallback to direct logs
docker compose logs --since=5m
```

### Build Failures

```bash
# Clean build
cd docker && make build-runtime-no-cache

# Check builder image
docker images | grep ollama37-builder
```

## Error Patterns

The test framework checks for these critical errors:

| Pattern | Severity | Description |
|---------|----------|-------------|
| `CUBLAS_STATUS_*` | Critical | CUDA/cuBLAS error (K80-specific) |
| `CUDA error` | Critical | General CUDA failure |
| `cudaMalloc failed` | Critical | GPU memory allocation failure |
| `out of memory` | Critical | VRAM exhausted |
| `level=ERROR` | Warning | Ollama application error |
| `panic`, `fatal` | Critical | Runtime crash |
| `id=cpu library=cpu` | Critical | CPU-only fallback (GPU not detected) |

## File Structure

```
tests/
├── src/
│   ├── cli.ts           # CLI entry point
│   ├── executor.ts      # Test execution engine
│   ├── judge.ts         # LLM/simple judging
│   ├── loader.ts        # YAML test case parser
│   ├── log-collector.ts # Docker log collector
│   ├── reporter.ts      # Output formatters
│   └── types.ts         # Type definitions
├── testcases/
│   ├── build/           # Build test cases
│   ├── runtime/         # Runtime test cases
│   └── inference/       # Inference test cases
└── package.json

.github/workflows/
├── build.yml            # Build verification
├── runtime.yml          # Container/GPU tests
├── inference.yml        # Model inference tests
└── full-pipeline.yml    # Complete pipeline
```
