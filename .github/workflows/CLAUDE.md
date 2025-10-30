# GitHub Actions Workflows - Tesla K80 Testing

## Overview

This directory contains workflows for automated testing of ollama37 on Tesla K80 (CUDA Compute Capability 3.7) hardware.

## Workflows

### 1. tesla-k80-ci.yml - Build Workflow
**Trigger**: Manual only (`workflow_dispatch`)

**Purpose**: Build the ollama binary with CUDA 3.7 support

**Steps**:
1. Checkout code
2. Clean previous build artifacts
3. Configure CMake with GCC 10 and CUDA 11
4. Build C++/CUDA components
5. Build Go binary
6. Verify binary
7. Upload binary artifact

**Artifacts**: `ollama-binary-{sha}` - Compiled binary for the commit

### 2. tesla-k80-tests.yml - Test Workflow
**Trigger**: Manual only (`workflow_dispatch`)

**Purpose**: Run comprehensive tests using the test framework

**Steps**:
1. Checkout code
2. Verify ollama binary exists
3. Run test-runner tool (see below)
4. Upload test results and logs

**Artifacts**: Test reports, logs, analysis results

## Test Framework Architecture

### TODO: Implement Go-based Test Runner

**Goal**: Create a dedicated Go test orchestrator at `cmd/test-runner/main.go` that manages the complete test lifecycle for Tesla K80.

#### Task Breakdown

1. **Design test configuration format**
   - Create `test/config/models.yaml` - List of models to test with parameters
   - Define model test spec: name, size, expected behavior, test prompts
   - Support test profiles: quick (small models), full (all sizes), stress test

2. **Implement server lifecycle management**
   - Start `./ollama serve` as subprocess
   - Capture stdout/stderr to log file
   - Monitor server readiness (health check API)
   - Graceful shutdown on test completion or failure
   - Timeout handling for hung processes

3. **Implement real-time log monitoring**
   - Goroutine to tail server logs
   - Pattern matching for critical events:
     - GPU initialization messages
     - Model loading progress
     - CUDA errors or warnings
     - Memory allocation failures
     - CPU fallback warnings
   - Store events for later analysis

4. **Implement model testing logic**
   - For each model in config:
     - Pull model via API (if not cached)
     - Wait for model ready
     - Parse logs for GPU loading confirmation
     - Send chat API request with test prompt
     - Validate response (not empty, reasonable length, coherent)
     - Check logs for errors during inference
     - Record timing metrics (load time, first token, completion)

5. **Implement test validation**
   - GPU loading verification:
     - Parse logs for "loaded model" + GPU device ID
     - Check for "offloading N layers to GPU"
     - Verify no "using CPU backend" messages
   - Response quality checks:
     - Response not empty
     - Minimum token count (avoid truncated responses)
     - JSON structure valid (for API responses)
   - Error detection:
     - No CUDA errors in logs
     - No OOM (out of memory) errors
     - No model loading failures

6. **Implement structured reporting**
   - Generate JSON report with:
     - Test summary (pass/fail/skip counts)
     - Per-model results (status, timings, errors)
     - Log excerpts for failures
     - GPU metrics (memory usage, utilization)
   - Generate human-readable summary (markdown/text)
   - Exit code: 0 for all pass, 1 for any failure

7. **Implement CLI interface**
   - Flags:
     - `--config` - Path to test config file
     - `--profile` - Test profile to run (quick/full/stress)
     - `--ollama-bin` - Path to ollama binary (default: ./ollama)
     - `--output` - Report output path
     - `--verbose` - Detailed logging
     - `--keep-models` - Don't delete models after test
   - Subcommands:
     - `run` - Run tests
     - `validate` - Validate config only
     - `list` - List available test profiles/models

8. **Update GitHub Actions workflow**
   - Build test-runner binary in CI workflow
   - Run test-runner in test workflow
   - Parse JSON report for pass/fail
   - Upload structured results as artifacts

#### File Structure

```
cmd/test-runner/
  main.go              # CLI entry point
  config.go            # Config loading and validation
  server.go            # Server lifecycle management
  monitor.go           # Log monitoring and parsing
  test.go              # Model test execution
  validate.go          # Response and log validation
  report.go            # Test report generation

test/config/
  models.yaml          # Default test configuration
  quick.yaml           # Quick test profile (small models)
  full.yaml            # Full test profile (all sizes)

.github/workflows/
  tesla-k80-ci.yml     # Build workflow (manual)
  tesla-k80-tests.yml  # Test workflow (manual, uses test-runner)
```

#### Example Test Configuration (models.yaml)

```yaml
profiles:
  quick:
    models:
      - name: gemma2:2b
        prompts:
          - "Hello, respond with a greeting."
        min_response_tokens: 5
        timeout: 30s
      
  full:
    models:
      - name: gemma2:2b
        prompts:
          - "Hello, respond with a greeting."
          - "What is 2+2?"
        min_response_tokens: 5
        timeout: 30s
      
      - name: gemma3:4b
        prompts:
          - "Explain photosynthesis in one sentence."
        min_response_tokens: 10
        timeout: 60s
      
      - name: gemma3:12b
        prompts:
          - "Write a haiku about GPUs."
        min_response_tokens: 15
        timeout: 120s

validation:
  gpu_required: true
  check_patterns:
    success:
      - "loaded model"
      - "offload.*GPU"
    failure:
      - "CUDA.*error"
      - "out of memory"
      - "CPU backend"
```

#### Example Test Runner Usage

```bash
# Build test runner
go build -o test-runner ./cmd/test-runner

# Run quick test profile
./test-runner run --config test/config/models.yaml --profile quick

# Run full test with verbose output
./test-runner run --profile full --verbose --output test-report.json

# Validate config only
./test-runner validate --config test/config/models.yaml

# List available profiles
./test-runner list
```

#### Integration with GitHub Actions

```yaml
- name: Build test runner
  run: go build -o test-runner ./cmd/test-runner

- name: Run tests
  run: |
    ./test-runner run --profile full --output test-report.json --verbose
  timeout-minutes: 45

- name: Check test results
  run: |
    if ! jq -e '.summary.failed == 0' test-report.json; then
      echo "Tests failed!"
      jq '.failures' test-report.json
      exit 1
    fi

- name: Upload test report
  uses: actions/upload-artifact@v4
  with:
    name: test-report
    path: |
      test-report.json
      ollama.log
```

## Prerequisites

### Self-Hosted Runner Setup

1. **Install GitHub Actions Runner on your Tesla K80 machine**:
   ```bash
   mkdir -p ~/actions-runner && cd ~/actions-runner
   curl -o actions-runner-linux-x64-2.XXX.X.tar.gz -L \
     https://github.com/actions/runner/releases/download/vX.XXX.X/actions-runner-linux-x64-2.XXX.X.tar.gz
   tar xzf ./actions-runner-linux-x64-2.XXX.X.tar.gz
   
   # Configure (use token from GitHub)
   ./config.sh --url https://github.com/YOUR_USERNAME/ollama37 --token YOUR_TOKEN
   
   # Install and start as a service
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

2. **Verify runner environment has**:
   - CUDA 11.4+ toolkit installed
   - GCC 10 at `/usr/local/bin/gcc` and `/usr/local/bin/g++`
   - CMake 3.24+
   - Go 1.24+
   - NVIDIA driver with Tesla K80 support
   - Network access to download models

## Security Considerations

- Self-hosted runners should be on a secure, isolated machine
- Consider using runner groups to restrict repository access
- Do not use self-hosted runners for public repositories (untrusted PRs)
- Keep runner software updated
