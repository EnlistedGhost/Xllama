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
1. Read the issue to understand requirements
2. Decide flow using `git-flow` skill (branch vs commit-on-main)
3. Create a branch named after the issue (e.g. `issue-12-add-feature`)
4. Implement the changes
5. Add tests if needed (see `add-test` skill)
6. Build and test (see `build`, `test`, `ci` skills)
7. Create a PR that references the issue (`Fixes #N`)
8. Update the issue with a comment summarizing what was done

## Issue updates
Always update GitHub issues to reflect progress:
- **On start**: Add a comment noting work has begun and link the branch
- **On completion**: Add a comment summarizing changes made, linking the PR
- **On partial fix**: Add a comment describing what was fixed, what remains, and any blockers
- Use `gh issue comment <number> --body "<message>"` to post updates
- The PR description should include `Fixes #N` or `Closes #N` to auto-close on merge

## Branch naming
`issue-<number>-<short-slug>` (e.g. `issue-12-cuda-debug-logging`)
