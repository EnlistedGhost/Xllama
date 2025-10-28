# GitHub Actions Workflows

## Tesla K80 CI Workflow

The `tesla-k80-ci.yml` workflow builds and tests ollama with CUDA Compute Capability 3.7 support using a self-hosted runner.

### Prerequisites

#### Self-Hosted Runner Setup

1. **Install GitHub Actions Runner on your Tesla K80 machine**:
   ```bash
   # Navigate to your repository on GitHub:
   # Settings > Actions > Runners > New self-hosted runner
   
   # Follow the provided instructions to download and configure the runner
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
   - Go 1.24+ (or let the workflow install it)
   - NVIDIA driver with Tesla K80 support
   - Network access to download Go dependencies and models
   - **Claude CLI** installed and configured (`claude -p` must be available)
     - Install: Follow instructions at https://docs.claude.com/en/docs/claude-code/installation
     - The runner needs API access to use Claude for log analysis

3. **Optional: Add runner labels**:
   - You can add custom labels like `tesla-k80`, `cuda`, `gpu` during runner configuration
   - Then target specific runners by uncommenting the labeled `runs-on` line in the workflow

#### Environment Variables (Optional)

You can set repository secrets or environment variables for:
- `OLLAMA_DEBUG=1` - Enable debug logging
- `OLLAMA_MODELS` - Custom model storage path
- Any other ollama configuration

### Workflow Triggers

The workflow runs on:
- **Push** to `main` or `develop` branches
- **Pull requests** to `main` branch
- **Manual dispatch** via GitHub Actions UI

### Workflow Steps

1. **Environment Setup**: Checkout code, install Go, display system info
2. **Build**: Clean previous builds, configure CMake with GCC 10, build C++/CUDA components and Go binary
3. **Unit Tests**: Run Go unit tests with race detector
4. **Integration Tests**: Start ollama server, wait for ready, run integration tests
5. **Model Tests**: Pull gemma2:2b, run inference, verify GPU acceleration
6. **Log Analysis**: Use Claude headless mode to validate model loaded properly with Tesla K80
7. **Cleanup**: Stop server, upload logs/artifacts

### Artifacts

- **ollama-logs-and-analysis** (always): Server logs, Claude analysis prompt, and analysis result
- **ollama-binary-{sha}** (on success): Compiled ollama binary for the commit

### Log Analysis with Claude

The workflow uses Claude in headless mode (`claude -p`) to intelligently analyze ollama server logs and verify proper Tesla K80 GPU initialization. This provides automated validation that:

1. **Model Loading**: Gemma2:2b loaded without errors
2. **GPU Acceleration**: CUDA properly detected and initialized for Compute 3.7
3. **No CPU Fallback**: Model is running on GPU, not falling back to CPU
4. **No Compatibility Issues**: No CUDA version warnings or errors
5. **Memory Allocation**: Successful GPU memory allocation
6. **Inference Success**: Model inference completed without errors

**Analysis Results**:
- `PASS`: All checks passed, model working correctly with GPU
- `WARN: <reason>`: Model works but has warnings worth reviewing
- `FAIL: <reason>`: Critical issues detected, workflow fails

This approach is superior to simple grep/pattern matching because Claude can:
- Understand context and correlate multiple log entries
- Distinguish between critical errors and benign warnings
- Identify subtle issues like silent CPU fallback
- Provide human-readable explanations of problems

**Example**: If logs show "CUDA initialization successful" but later "using CPU backend", Claude will catch this inconsistency and fail the test, while simple pattern matching might miss it.

### Customization

#### Testing different models

Uncomment and expand the "Test model operations" step:

```yaml
- name: Test model operations
  run: |
    ./ollama pull llama3.2:1b
    ./ollama run llama3.2:1b "test prompt" --verbose
    nvidia-smi  # Verify GPU was used
```

#### Running on specific branches

Modify the `on` section:

```yaml
on:
  push:
    branches: [ main, develop, feature/* ]
```

#### Scheduled runs

Add cron schedule for nightly builds:

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
```

### Troubleshooting

**Runner offline**: Check runner service status
```bash
sudo systemctl status actions.runner.*
```

**Build failures**: Check uploaded logs in Actions > workflow run > Artifacts

**GPU not detected**: Verify `nvidia-smi` works on the runner machine

**Permissions**: Ensure runner user has access to CUDA libraries and can bind to port 11434

### Security Considerations

- Self-hosted runners should be on a secure, isolated machine
- Consider using runner groups to restrict which repositories can use the runner
- Do not use self-hosted runners for public repositories (untrusted PRs)
- Keep the runner software updated
