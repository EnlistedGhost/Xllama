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

### Git Flow

See `git-flow` skill for the decision framework. In short: code changes use branch flow (branch → PR → merge), docs-only changes can commit directly to `main`.

## Skills and Commands

Skills (`.claude/skills/`) define capabilities and when to use them:
- **`build`** — Build environment, types, and references
- **`debug`** — Debug capabilities and environment variables
- **`ci`** — CI/CD workflows and runner environment
- **`test`** — Local test framework and test suites
- **`git-flow`** — Branch flow vs commit-on-main decision
- **`plan`** — Break down requests into GitHub Issues
- **`implement`** — Start work on a GitHub Issue
- **`add-test`** — Add test cases to the test framework

Commands (`.claude/commands/`) are user-invoked slash commands:
- **`/build`** — Step-by-step native and Docker build instructions
- **`/debug`** — Debug logging commands for native and Docker
- **`/ci`** — Trigger and check GitHub Actions workflows
- **`/test`** — Run test suites locally (build, runtime, inference, models)
- **`/plan`** — Break down a request into GitHub Issues
- **`/implement`** — Pick up an issue, create branch, do work, create PR
- **`/add-test`** — Add a YAML test case and spec entry
