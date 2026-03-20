---
name: merge
description: Merge an approved PR and clean up branch and labels. Use when a PR is approved and ready to merge. This is the MERGED state in the Development Lifecycle.
argument-hint: <pr-number>
---

# Merge

Merge an approved pull request and clean up. Use `/merge` to start.

**Lifecycle state**: MERGED (terminal state — see Development Lifecycle in CLAUDE.md)

## When to use
- After `/review-pr` has approved the PR
- PR is ready to merge

## Workflow

### 1. Verify PR is approved
```bash
gh pr view <PR> --json reviewDecision,mergeStateStatus
```
- Must be approved and mergeable
- CI checks must pass

### 2. Merge the PR
```bash
gh pr merge <PR> --merge --delete-branch
```
- Use `--merge` (not squash or rebase) to preserve commit history
- `--delete-branch` cleans up the remote branch

### 3. Clean up issue labels
```bash
gh issue edit <N> --remove-label "status:needs-review"
```
- Issue auto-closes via `Fixes #N` in PR body
- No need to close manually

### 4. Clean up local branch
```bash
git checkout main
git pull
git branch -d <branch-name>
```

### 5. Report back
- Confirm merge to the user
- Show the merged PR URL
- Mention any follow-up issues if applicable
