# CI/CD Plan for Ollama37

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
│    - GitHub Actions Runner (self-hosted, labels: k80, cuda11)          │
│                                                                         │
│  Services:                                                              │
│    - TestLink (http://localhost:8090) - Test management                │
│    - TestLink MCP - Claude Code integration                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                                                      │
                                                                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         SERVE NODE                                       │
│                                                                         │
│  Services:                                                              │
│    - Ollama (production)                                               │
│    - Dify (LLM application platform)                                   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Build Strategy: Docker-Based

We use the two-stage Docker build system located in `/docker/`:

### Stage 1: Builder Image (Cached)

**Image:** `ollama37-builder:latest` (~15GB)

**Contents:**
- Rocky Linux 8
- CUDA 11.4 toolkit
- GCC 10 (built from source)
- CMake 4.0 (built from source)
- Go 1.25.3

**Build time:** ~90 minutes (first time only, then cached)

**Build command:**
```bash
cd docker && make build-builder
```

### Stage 2: Runtime Image (Per Build)

**Image:** `ollama37:latest` (~18GB)

**Process:**
1. Clone source from GitHub
2. Configure with CMake ("CUDA 11" preset)
3. Build C/C++/CUDA libraries
4. Build Go binary
5. Package runtime environment

**Build time:** ~10 minutes

**Build command:**
```bash
cd docker && make build-runtime
```

## Pipeline Stages

### Stage 1: Docker Build

**Trigger:** Push to `main` branch

**Steps:**
1. Checkout repository
2. Ensure builder image exists (build if not)
3. Build runtime image: `make build-runtime`
4. Verify image created successfully

**Test Cases:**
- TC-BUILD-001: Builder Image Verification
- TC-BUILD-002: Runtime Image Build
- TC-BUILD-003: Image Size Validation

### Stage 2: Container Startup

**Steps:**
1. Start container with GPU: `docker compose up -d`
2. Wait for health check to pass
3. Verify Ollama server is responding

**Test Cases:**
- TC-RUNTIME-001: Container Startup
- TC-RUNTIME-002: GPU Detection
- TC-RUNTIME-003: Health Check

### Stage 3: Inference Tests

**Steps:**
1. Pull test model (gemma3:4b)
2. Run inference tests
3. Verify CUBLAS legacy fallback

**Test Cases:**
- TC-INFERENCE-001: Model Pull
- TC-INFERENCE-002: Basic Inference
- TC-INFERENCE-003: API Endpoint Test
- TC-INFERENCE-004: CUBLAS Fallback Verification

### Stage 4: Cleanup & Report

**Steps:**
1. Stop container: `docker compose down`
2. Report results to TestLink
3. Clean up resources

## Test Case Design

### Build Tests (Suite: Build Tests)

| ID | Name | Type | Description |
|----|------|------|-------------|
| TC-BUILD-001 | Builder Image Verification | Automated | Verify builder image exists with correct tools |
| TC-BUILD-002 | Runtime Image Build | Automated | Build runtime image from GitHub source |
| TC-BUILD-003 | Image Size Validation | Automated | Verify image sizes are within expected range |

### Runtime Tests (Suite: Runtime Tests)

| ID | Name | Type | Description |
|----|------|------|-------------|
| TC-RUNTIME-001 | Container Startup | Automated | Start container with GPU passthrough |
| TC-RUNTIME-002 | GPU Detection | Automated | Verify Tesla K80 detected inside container |
| TC-RUNTIME-003 | Health Check | Automated | Verify Ollama health check passes |

### Inference Tests (Suite: Inference Tests)

| ID | Name | Type | Description |
|----|------|------|-------------|
| TC-INFERENCE-001 | Model Pull | Automated | Pull gemma3:4b model |
| TC-INFERENCE-002 | Basic Inference | Automated | Run simple prompt and verify response |
| TC-INFERENCE-003 | API Endpoint Test | Automated | Test /api/generate endpoint |
| TC-INFERENCE-004 | CUBLAS Fallback Verification | Automated | Verify legacy CUBLAS functions used |

## GitHub Actions Workflow

**File:** `.github/workflows/build-test.yml`

**Triggers:**
- Push to `main` branch
- Pull request to `main` branch
- Manual trigger (workflow_dispatch)

**Runner:** Self-hosted with labels `[self-hosted, k80, cuda11]`

**Jobs:**
1. `build` - Build Docker runtime image
2. `test` - Run inference tests in container
3. `report` - Report results to TestLink

## TestLink Integration

**URL:** http://localhost:8090

**Project:** ollama37

**Test Suites:**
- Build Tests
- Runtime Tests
- Inference Tests

**Test Plan:** Created per release/sprint

**Builds:** Created per CI run (commit SHA)

**Execution Recording:**
- Each test case result recorded via TestLink API
- Pass/Fail status with notes
- Linked to specific build/commit

## Makefile Targets for CI

| Target | Description | When to Use |
|--------|-------------|-------------|
| `make build-builder` | Build base image | First time setup |
| `make build-runtime` | Build from GitHub | Normal CI builds |
| `make build-runtime-no-cache` | Fresh GitHub clone | When cache is stale |
| `make build-runtime-local` | Build from local | Local testing |

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

### TestLink Environment

| Variable | Value | Description |
|----------|-------|-------------|
| `TESTLINK_URL` | http://localhost:8090 | TestLink server URL |
| `TESTLINK_API_KEY` | (configured) | API key for automation |

## Prerequisites

### One-Time Setup on CI/CD Node

1. **Install GitHub Actions Runner:**
   ```bash
   mkdir -p ~/actions-runner && cd ~/actions-runner
   curl -o actions-runner-linux-x64-2.321.0.tar.gz -L \
     https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz
   tar xzf ./actions-runner-linux-x64-2.321.0.tar.gz
   ./config.sh --url https://github.com/dogkeeper886/ollama37 --token YOUR_TOKEN --labels k80,cuda11
   sudo ./svc.sh install && sudo ./svc.sh start
   ```

2. **Build Builder Image (one-time, ~90 min):**
   ```bash
   cd /home/jack/src/ollama37/docker
   make build-builder
   ```

3. **Verify GPU Access in Docker:**
   ```bash
   docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
   ```

4. **Start TestLink:**
   ```bash
   cd /home/jack/src/testlink-code
   docker compose up -d
   ```

## Monitoring & Logs

### View CI/CD Logs

```bash
# GitHub Actions Runner logs
journalctl -u actions.runner.* -f

# Docker build logs
docker compose logs -f

# TestLink logs
cd /home/jack/src/testlink-code && docker compose logs -f
```

### Test Results

- **TestLink Dashboard:** http://localhost:8090
- **GitHub Actions:** https://github.com/dogkeeper886/ollama37/actions

## Troubleshooting

### Builder Image Missing

```bash
cd docker && make build-builder
```

### GPU Not Detected in Container

```bash
# Check UVM device files on host
ls -l /dev/nvidia-uvm*

# Create if missing
nvidia-modprobe -u -c=0

# Restart container
docker compose restart
```

### Build Cache Stale

```bash
cd docker && make build-runtime-no-cache
```

### TestLink Connection Failed

```bash
# Check TestLink is running
curl http://localhost:8090

# Restart if needed
cd /home/jack/src/testlink-code && docker compose restart
```
