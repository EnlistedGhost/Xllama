# Claude Code Development Notes

This is an Ollama fork adding CUDA compute capability 3.7 support for Tesla K80 GPUs.

## Project Goals

### 1. CUDA Compute Capability 3.7 Support (Tesla K80)
- **Objective**: Add support for CUDA compute capability 3.7 to enable running on Tesla K80 GPUs
- **Environment**: GCC 10.5, CUDA 11.4.4, NVIDIA driver 470
- **Status**: Complete

### 2. Code Understanding and Documentation
- **Issue**: Upstream Ollama/llama.cpp lacks comments, making debugging and optimization difficult
- **Policy**: Use the `trace`, `instrument`, `profile`, and `annotate` skills to systematically understand and document code
- **Principle**: Measure first, annotate only what's verified, never guess

## Development Process

### Git Flow

See `git-flow` skill for the decision framework. In short: code changes use branch flow (branch → PR → merge), docs-only changes can commit directly to `main`.

## Skills and Commands

When creating or updating skills and commands, follow the format guides in `.claude/references/`:
- `skill-format.md` — Skill file structure, frontmatter fields, best practices
- `command-format.md` — Slash command format, arguments, dynamic context

**Design principle**: Skills define *when* and *what* (auto-loaded every conversation). Commands define *how* to do the thing (invoked via `/slash`). Keep executable content (code patterns, runnable commands) in commands, not skills.

Skills (`.claude/skills/`) define capabilities and when to use them:
- **`build`** — Build environment, types, and references
- **`debug`** — Debug capabilities and environment variables
- **`ci`** — CI/CD workflows and runner environment
- **`test`** — Local test framework and test suites
- **`git-flow`** — Branch flow vs commit-on-main decision
- **`plan`** — Break down requests into GitHub Issues
- **`implement`** — Start work on a GitHub Issue
- **`add-test`** — Add test cases to the test framework
- **`trace`** — Trace a code path to understand execution flow
- **`instrument`** — Add timing code to measure performance
- **`profile`** — Run system profiling tools (perf, nvprof, strace)
- **`annotate`** — Add verified comments and architecture docs

Commands (`.claude/commands/`) are user-invoked slash commands:
- **`/build`** — Step-by-step native and Docker build instructions
- **`/debug`** — Debug logging commands for native and Docker
- **`/ci`** — Trigger and check GitHub Actions workflows
- **`/test`** — Run test suites locally (build, runtime, inference, models)
- **`/plan`** — Break down a request into GitHub Issues
- **`/implement`** — Pick up an issue, create branch, do work, create PR
- **`/add-test`** — Add a YAML test case and spec entry
- **`/trace`** — Trace a code path and produce a call-flow summary
- **`/instrument`** — Add timing instrumentation to measure performance
- **`/profile`** — Show profiling commands for a scenario
- **`/annotate`** — Add verified annotations to investigated code
