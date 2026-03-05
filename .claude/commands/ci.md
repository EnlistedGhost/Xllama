Help the user trigger or check CI workflows. Reference `.claude/skills/ci.md` for context.

## Trigger a workflow

```bash
# Build verification only
gh workflow run test-build.yml

# Container and runtime tests
gh workflow run test-runtime.yml

# Model inference tests
gh workflow run test-inference.yml

# Model compatibility tests
gh workflow run test-models.yml

# Full pipeline (build -> runtime -> inference -> models)
gh workflow run test-pipeline.yml
```

## Check workflow status

```bash
# List recent workflow runs
gh run list

# View a specific run
gh run view <run-id>

# Watch a running workflow
gh run watch <run-id>
```
