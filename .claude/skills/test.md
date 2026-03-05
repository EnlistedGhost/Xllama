---
name: test
description: Run the ollama37 test framework locally. Use when running build, runtime, inference, or model tests against a local Docker container.
argument-hint: [build|runtime|inference|models]
---

# Test Skill

## What
TypeScript-based test framework with dual-judge architecture (simple + LLM) for validating ollama37 builds on Tesla K80 GPUs.

## When to use
- Validating a Docker build locally before pushing
- Running specific test suites (build, runtime, inference, models)
- Debugging test failures
- Running tests without the LLM judge

## Test suites
| Suite | Purpose |
|-------|---------|
| build | Verify Docker images and toolchain |
| runtime | Container startup, GPU detection |
| inference | Model loading, API endpoints |
| models | Large model testing (gpt-oss, gemma3:27b, deepseek-r1) |

## Architecture
- Test definitions: `cicd/tests/testcases/` (YAML)
- Test specs: `cicd/specs/`
- Framework source: `cicd/tests/src/`
- LLM judge: separate Ollama instance on port 11435 (stable reference from DockerHub)
- Test subject: local build on port 11434

## Key references
- `cicd/README.md` — Full test framework documentation
- `cicd/docs/CICD.md` — Design philosophy
