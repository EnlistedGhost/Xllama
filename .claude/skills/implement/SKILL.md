---
name: implement
description: Start work on a GitHub Issue. Use when picking up an issue to implement — creates a branch, codes, builds, and tests. This is the IMPLEMENTING state in the Development Lifecycle.
argument-hint: <issue-number>
---

# Implement

Pick up a GitHub Issue and start implementation — create a branch, do the work, build, and test. Use `/implement` to start.

**Lifecycle state**: IMPLEMENTING → TESTING (see Development Lifecycle in CLAUDE.md)

## When to use
- After `/plan` has created issues and **user has approved**
- When the user wants to start working on a specific issue

## Workflow

### 1. Understand
- Read the issue fully: `gh issue view <N>`
- Check for linked issues, dependencies, or prior attempts
- Check labels — priority and component should already be set
- If anything is unclear, ask the user before starting

### 2. Start
- Decide flow using `git-flow` skill (branch vs commit-on-main)
- Create branch: `issue-<N>-<short-slug>` from `main`
- Comment on the issue: `gh issue comment <N> --body "Starting work on branch \`issue-<N>-<slug>\`"`
- Add `status:in-progress` label: `gh issue edit <N> --add-label "status:in-progress"`

### 3. Implement
- Make the changes
- Add tests if needed (see `add-test` skill)
- Build and test (see `build`, `test`, `ci` skills)

### 4. On failure (build fails, test fails, runtime error)
- **Do NOT silently retry.** Update the issue with what failed:
  `gh issue comment <N> --body "Build/test failure: <what failed, error, root cause hypothesis>"`
- Add `status:blocked` label if stuck:
  `gh issue edit <N> --add-label "status:blocked"`
- Investigate, apply fix, update issue again:
  `gh issue comment <N> --body "Applied fix: <what changed and why>. Retesting."`
- Remove blocked label after unblocking:
  `gh issue edit <N> --remove-label "status:blocked"`
- If stuck after 2-3 attempts, comment with blockers and ask the user

### 5. On success (tests pass)
- Comment on issue: `gh issue comment <N> --body "Implementation complete, tests passing. Ready for PR."`
- Proceed to `/create-pr` to open a pull request

### 6. On partial fix
- Comment: what was fixed, what remains, and blockers
- Proceed to `/create-pr` if the partial fix is independently useful
- Create follow-up issues for remaining work

## Issue cross-references
- **Parent/child**: mention in body — `Part of #N` or `Parent: #N`
- **Dependencies**: `Depends on #N`, `Blocked by #N`
- **Related**: `Related to #N`
- GitHub auto-creates backlinks when issues reference each other

## Key principle
The issue is the single source of truth. Anyone reading it should see the full history — start, failures, fixes, and resolution.

## Branch naming
`issue-<number>-<short-slug>` (e.g. `issue-12-cuda-debug-logging`)
