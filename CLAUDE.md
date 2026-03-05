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

Most code changes that affect the compiled binary or CUDA libraries require a Docker container rebuild to verify. See `/build` and `/ci` commands for details.

## Skills and Commands

Skills (`.claude/skills/`) define capabilities and when to use them:
- **`build`** — Build environment, types, and references
- **`debug`** — Debug capabilities and environment variables
- **`ci`** — CI/CD workflows and runner environment
- **`test`** — Local test framework and test suites

Commands (`.claude/commands/`) are user-invoked slash commands:
- **`/build`** — Step-by-step native and Docker build instructions
- **`/debug`** — Debug logging commands for native and Docker
- **`/ci`** — Trigger and check GitHub Actions workflows
- **`/test`** — Run test suites locally (build, runtime, inference, models)
