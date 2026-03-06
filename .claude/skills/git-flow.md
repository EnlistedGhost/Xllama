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
1. Create a feature branch from `main`
2. Commit changes to the branch
3. Test — run `/test` locally or `/ci` via GitHub Actions
4. Create PR against `main`
5. Review the PR
6. Merge to `main` after approval
7. Delete the branch after merge

## Commit on main
For changes that don't need testing: review the diff, commit directly to `main`.
