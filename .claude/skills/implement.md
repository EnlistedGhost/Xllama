---
name: implement
description: Start work on a GitHub Issue. Use when picking up an issue to implement — creates a branch, links the PR to the issue.
argument-hint: <issue-number>
---

# Implement Skill

## What
Pick up a GitHub Issue and start implementation — create a branch, do the work, create a PR that closes the issue.

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

## Branch naming
`issue-<number>-<short-slug>` (e.g. `issue-12-cuda-debug-logging`)
