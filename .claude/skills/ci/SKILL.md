---
name: ci
description: Run CI/CD workflows for ollama37. Use when building or testing on a remote runner, triggering GitHub Actions, or deciding between local vs CI builds.
---

# CI

Run build and test workflows via GitHub Actions on a self-hosted runner with K80 GPU access. Use `/ci` to trigger.

## When to use
- Developing on a machine without K80 hardware
- Running the full test pipeline before merging a PR
- Verifying builds on actual K80 GPU hardware

## Available workflows
- `test-build.yml` — Build verification only
- `test-runtime.yml` — Container and runtime tests
- `test-inference.yml` — Model inference tests
- `test-models.yml` — Model compatibility tests
- `test-pipeline.yml` — Full pipeline (build -> runtime -> inference -> models)

## Runner environment
- All workflows run on `self-hosted` runners in the `cicd-1` environment (K80 GPUs)
- Trigger manually: Actions tab -> select workflow -> "Run workflow"

## Local vs CI
- Machine with K80 → local `make build-runtime-local` is faster, run tests locally with `/test`
- Machine without K80 → trigger GitHub Actions
- Always run full test pipeline before merging a PR

## Related
- `test` skill — Run tests locally (same suites that CI runs remotely)
