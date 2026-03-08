---
name: git-flow
description: Determines the correct git workflow for a change. Use before committing to decide between branch flow (PR) or direct commit to main.
---

# Git Flow

Decision framework for how to commit changes — branch with PR, or direct to main.

## When to use
- Before committing any change

## Decision

Ask: **does this change need testing?**

| Answer | Flow | Examples |
|--------|------|----------|
| Yes | **Branch flow** | Code, Dockerfiles, Makefile, CI workflows, test framework, config that affects runtime |
| No | **Commit on main** | Docs, typos, README updates, skill/command edits, comments |

When in doubt, use branch flow.

## Branch flow
1. Create a feature branch from `main`: `issue-<N>-<slug>`
2. Commit changes to the branch
3. Test — run `/test` locally or `/ci` via GitHub Actions
4. Push and create PR against `main`
5. Run CI on the branch: `gh workflow run test-pipeline.yml --ref <branch>`
6. After CI passes, merge:
   ```bash
   gh pr merge <PR> --merge --delete-branch
   ```
7. Update related issues after merge

## PR conventions
- Title: short, imperative (under 70 chars)
- Body: `Fixes #N` or `Closes #N` to auto-close issues
- Body: `## Summary` + `## Test plan` sections
- Labels: copy from the issue (priority + component)

## Commit on main
For changes that don't need testing: review the diff, commit directly to `main`.

## Stacking branches
When a feature branch depends on another unmerged branch:
```bash
git checkout -b issue-<N>-<slug> issue-<parent>-<slug>
```
Set PR base to the parent branch, not main. After parent merges, rebase onto main.
