# Claude Code Development Notes

This is an Ollama fork adding CUDA compute capability 3.7 support for Tesla K80 GPUs.

## Project Goals

### 1. CUDA Compute Capability 3.7 Support (Tesla K80)
- **Objective**: Add support for CUDA compute capability 3.7 to enable running on Tesla K80 GPUs
- **Environment**: GCC 10.5, CUDA 11.4.4, NVIDIA driver 470
- **Status**: Complete

### 2. Code Documentation Policy
- **Issue**: This repo is cloned from official Ollama, which lacks code comments, making debugging difficult
- **Policy**: Add helpful comments when figuring out code functionality
- **Rationale**: Improve code maintainability and debugging experience

## Development Process

### Branch Workflow

All changes follow a branch-based workflow:

1. **Create a feature branch** from `main`
2. **Commit changes** to the branch
3. **Create a PR** for review
4. **Review the PR** - verify changes, check build/test results
5. **Merge to main** after approval
6. **Delete the branch** after merge

### Building and Testing

Most code changes that affect the compiled binary or CUDA libraries require a Docker container rebuild to verify.

**Local build (when on a host WITH K80 hardware):**
```bash
cd docker
make build-runtime-local
```

**GitHub Actions (when on a host WITHOUT K80 hardware):**

Use the GitHub Actions workflows to build and test on a self-hosted runner that has K80 GPU access. This avoids issues where builds on hardware without K80 may not catch GPU-specific problems.

- **Trigger manually**: Go to Actions tab -> select workflow -> "Run workflow"
- **Available workflows**:
  - `test-build.yml` - Build verification only
  - `test-runtime.yml` - Container and runtime tests
  - `test-inference.yml` - Model inference tests
  - `test-models.yml` - Model compatibility tests
  - `test-pipeline.yml` - Full pipeline (build -> runtime -> inference -> models)
- All workflows run on `self-hosted` runners in the `cicd-1` environment (which has K80 GPUs)

**When to use GitHub Actions vs local build:**
- Developing on a machine with K80 -> local `make build-runtime-local` is faster
- Developing on a machine without K80 -> trigger GitHub Actions workflow to build and test on the K80 runner
- Always run the full test pipeline before merging a PR

## Skills Reference

Detailed technical knowledge is organized into project skills at `.claude/skills/`:

- **`cuda-compat`** - K80 CUBLAS compatibility, CUDA version constraints, CPU architecture details (auto-loaded when relevant)
- **`/build`** - Native and Docker build instructions (invoke with `/build`)
- **`/debug`** - Debug logging options and troubleshooting (invoke with `/debug`)
