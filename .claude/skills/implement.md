---
name: implement
description: Start work on a GitHub Issue. Use when picking up an issue to implement — creates a branch, links the PR to the issue.
argument-hint: <issue-number>
---

# Implement

Pick up a GitHub Issue and start implementation — create a branch, do the work, create a PR that closes the issue. Use `/implement` to start.

## When to use
- After `/plan` has created issues
- When the user wants to start working on a specific issue

## Workflow

### 1. Understand
- Read the issue fully: `gh issue view <N>`
- Check for linked issues, dependencies, or prior attempts
- If anything is unclear, ask the user before starting

### 2. Start
- Decide flow using `git-flow` skill (branch vs commit-on-main)
- Create branch: `issue-<N>-<short-slug>` from `main`
- Comment on the issue: `gh issue comment <N> --body "Starting work on branch \`issue-<N>-<slug>\`"`

### 3. Implement
- Make the changes
- Add tests if needed (see `add-test` skill)
- Build and test (see `build`, `test`, `ci` skills)

### 4. On failure (build fails, test fails, runtime error)
- **Do NOT silently retry.** Update the issue with what failed:
  `gh issue comment <N> --body "Build/test failure: <what failed, error, root cause hypothesis>"`
- Investigate, apply fix, update issue again:
  `gh issue comment <N> --body "Applied fix: <what changed and why>. Retesting."`
- If a second fix is needed, comment again — every attempt is logged
- If stuck after 2-3 attempts, comment with blockers and ask the user

### 5. On success
- Create PR with `Fixes #N` or `Closes #N` in body
- Comment on issue: `gh issue comment <N> --body "Fix applied in PR #<PR>. Summary: <changes>"`

### 6. On partial fix
- Comment: `gh issue comment <N> --body "Partial fix in PR #<PR>. Fixed: <X>. Remaining: <Y>. Blocker: <Z>"`

## Key principle
The issue is the single source of truth. Anyone reading it should see the full history — start, failures, fixes, and resolution.

## Branch naming
`issue-<number>-<short-slug>` (e.g. `issue-12-cuda-debug-logging`)
