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

## Skill Loading Rule

**Skills are NOT auto-loaded.** Only the skill name and one-line description appear in context. The full skill content (workflows, rules, formats) is only available after invoking it with the Skill tool.

**You MUST invoke the Skill tool to load a skill before following its workflow.** When a task matches a skill's trigger (listed below), load it first, then proceed. Do not guess at skill contents from memory — always load.

## GitHub Workflow

### Labels
Every issue must have **one type label** and **one priority label**. Add component labels as applicable.

| Category | Labels |
|----------|--------|
| Type | `feature`, `enhancement`, `bug`, `removal` |
| Priority | `priority:critical`, `priority:high`, `priority:medium`, `priority:low` |
| Component | `component:ggml`, `component:cuda`, `component:model`, `component:go`, `component:ci` |
| Status | `status:blocked`, `status:needs-review` |

### Project Board
- Project: "ollama37 Development" (project number 2, owner: dogkeeper886)
- Add issues to project: `gh project item-add 2 --owner dogkeeper886 --url <issue-url>`

### Issue Cross-References
GitHub auto-creates backlinks when issues reference each other. Use these patterns:
- `Depends on #N` / `Blocked by #N` — for dependencies
- `Part of #N` — for parent/child relationships
- `Related to #N` — for related issues
- `Fixes #N` / `Closes #N` — in PR body to auto-close issues on merge

## Implementation Workflow

This is the end-to-end flow for working on any project, issue, or story. **Always follow this flow** — it ensures issues stay up to date and failures are tracked.

### 1. Understand
- Read the issue/story fully (`gh issue view <N>`)
- Check for linked issues, dependencies, or prior attempts
- Check labels — priority and component should already be set
- If anything is unclear, ask the user before starting

### 2. Start
- Comment on the issue: work has begun, link the branch
  `gh issue comment <N> --body "Starting work on branch \`issue-<N>-<slug>\`"`
- Create branch: `issue-<N>-<short-slug>` from `main`

### 3. Implement
- Make the changes
- Build and test locally (load `build`, `test` skills as needed)

### 4. On failure (build fails, test fails, runtime error)
- **Do NOT silently retry.** Update the issue with what failed and why:
  `gh issue comment <N> --body "Build/test failure: <what failed, error message, root cause hypothesis>"`
- Add `status:blocked` label if stuck:
  `gh issue edit <N> --add-label "status:blocked"`
- Investigate, apply fix, update the issue again:
  `gh issue comment <N> --body "Applied fix: <what changed and why>. Retesting."`
- Remove blocked label after unblocking:
  `gh issue edit <N> --remove-label "status:blocked"`
- If stuck after 2-3 attempts, comment with blockers and ask the user

### 5. On success
- Create PR referencing the issue: `Fixes #N` or `Closes #N` in the PR body
- Add `status:needs-review` label:
  `gh issue edit <N> --add-label "status:needs-review"`
- Comment on the issue summarizing what was done:
  `gh issue comment <N> --body "Fix applied in PR #<PR>. Summary: <what changed>"`

### 6. On partial fix
- Comment describing what was fixed, what remains, and blockers:
  `gh issue comment <N> --body "Partial fix in PR #<PR>. Fixed: <X>. Remaining: <Y>. Blocker: <Z>"`

### 7. After merge
- Remove status labels: `gh issue edit <N> --remove-label "status:needs-review"`
- Issue auto-closes via `Fixes #N` in PR body
- Delete the branch: `git push origin --delete <branch>`

**Key principle**: The issue is the single source of truth. Anyone reading it should see the full history — start, failures, fixes, and resolution.

## Skill Quick Reference

Extracted triggers and key rules from each skill. Use these to recognize when to load a skill, and as a fallback if the Skill tool is unavailable.

### git-flow
- **Trigger**: Before committing any change
- **Rule**: Code changes → branch flow (branch → PR → merge). Docs-only → commit on main. When in doubt, branch flow.

### build
- **Trigger**: Compiling from source, building Docker images, verifying compiled changes
- **Key info**: CMake presets `"CUDA 11"` (all archs 37-86), `"CUDA 11 K80"` (K80 only). Docker: `docker/Makefile`. Native: cmake + go build.

### debug
- **Trigger**: Server startup failures, GPU detection issues, CUBLAS errors, runtime problems
- **Key info**: `OLLAMA_DEBUG=1` (server logging), `GGML_CUDA_DEBUG=1` (CUDA/CUBLAS logging)

### test
- **Trigger**: Validating builds, running test suites, debugging test failures
- **Key info**: Suites: build, runtime, inference, models. Framework: `cicd/tests/`. Docs: `cicd/README.md`

### ci
- **Trigger**: Remote builds/tests, GitHub Actions, pre-merge verification
- **Key info**: Workflows: `test-build.yml`, `test-runtime.yml`, `test-inference.yml`, `test-models.yml`, `test-pipeline.yml`. Runner: self-hosted `cicd-1` (K80)

### plan
- **Trigger**: User describes a feature, enhancement, removal, or bug to plan
- **Key info**: Create issues with type + priority + component labels. Add to project board. Link related issues. Use `gh issue create`.

### implement
- **Trigger**: Picking up a GitHub Issue to start work
- **Key info**: See **Implementation Workflow** section above for the full flow. Branch: `issue-<N>-<slug>`. PR: `Fixes #N`. Update labels (`status:blocked`, `status:needs-review`). Update issue on every state change.

### add-test
- **Trigger**: New feature or fix needs test coverage
- **Key info**: YAML test cases in `cicd/tests/testcases/<suite>/`. ID format: `TC-<SUITE>-<NNN>`. Required fields: id, name, suite, priority, timeout, dependencies, steps, criteria.

### trace
- **Trigger**: Investigating unfamiliar code, understanding execution flow, before modifying unknown code
- **Rules**: One path at a time. Start from log message. Note branch conditions. Verify with runtime.
- **Save split**: `docs/traces/` = full technical knowledge. GitHub issue = short status + link to trace doc. No duplication.

### instrument
- **Trigger**: Investigating slow loading, GPU transfer, unexplained latency
- **Rules**: Measure first, optimize second. Use `// INSTRUMENT:` prefix. Use existing logging (`LLAMA_LOG_INFO`, `slog`). Remove after confirming.
- **Key locations**: `init_mappings` (mmap), buffer alloc loop in `load_tensors` (VRAM), `load_all_data` (tensor transfer), `ggml_backend_tensor_set` (GPU uploads)

### profile
- **Trigger**: Performance issues, before reading code for bottlenecks
- **Rules**: Use `nvprof` (not `nsys` — CUDA 11.4/driver 470). K80 is PCIe Gen3 x16 (~8-10 GB/s).
- **Tools**: `perf` (CPU), `strace` (syscalls/IO), `nvprof` (GPU), page faults (memory)

### annotate
- **Trigger**: After confirming behavior through tracing, profiling, or debugging
- **Rules**: Only annotate verified behavior. Comment "why" not "what". Tags: `// VERIFIED:`, `// ASSUMPTION:`, `// NOTE:`. Architecture docs in `docs/arch/`.

## Skills and Commands

When creating or updating skills and commands, follow the format guides in `.claude/references/`:
- `skill-format.md` — Skill file structure, frontmatter fields, best practices
- `command-format.md` — Slash command format, arguments, dynamic context

**Design principle**: Skills define *when* and *what*. Commands define *how* (invoked via `/slash`). Keep executable content in commands, not skills.

### Skill files (`.claude/skills/`)
`build`, `debug`, `ci`, `test`, `git-flow`, `plan`, `implement`, `add-test`, `trace`, `instrument`, `profile`, `annotate`

### Slash commands (`.claude/commands/`)
`/build`, `/debug`, `/ci`, `/test`, `/plan`, `/implement`, `/add-test`, `/trace`, `/instrument`, `/profile`, `/annotate`
