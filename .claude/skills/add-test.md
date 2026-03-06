---
name: add-test
description: Add a test case to the ollama37 test framework. Use when a new feature or fix needs test coverage.
argument-hint: <suite> <test-name>
---

# Add Test

Create a new YAML test case and its spec entry for the ollama37 test framework. Use `/add-test` to create.

## When to use
- After implementing a feature that needs test coverage
- When adding regression tests for a bug fix
- When expanding test coverage for an existing suite

## Test suites
| Suite | Directory | ID prefix |
|-------|-----------|-----------|
| build | `cicd/tests/testcases/build/` | TC-BUILD |
| runtime | `cicd/tests/testcases/runtime/` | TC-RUNTIME |
| inference | `cicd/tests/testcases/inference/` | TC-INFERENCE |
| models | `cicd/tests/testcases/models/` | TC-MODELS |

## Test case format (YAML)
Required fields:
- `id` — Unique ID (e.g. `TC-BUILD-004`)
- `name` — Descriptive name
- `suite` — Suite name
- `priority` — Integer (1 = highest)
- `timeout` — Milliseconds
- `dependencies` — List of prerequisite test IDs
- `steps` — List of step objects
- `criteria` — LLM judge criteria string

## Step fields
- `name` — Step description
- `command` — Bash command to run
- `expectPatterns` — List of regex patterns that must match output
- `rejectPatterns` — List of regex patterns that must NOT match output
- `timeout` — Optional per-step timeout in milliseconds

## Related files
- Test cases: `cicd/tests/testcases/<suite>/`
- Specs: `cicd/specs/<suite>.md`
- Framework docs: `cicd/README.md`
