Merge an approved PR and clean up. Reference `.claude/skills/merge.md` for context.

The user will provide: **$ARGUMENTS** (a PR number)

## Steps

1. **Verify PR status**:

```bash
gh pr view $1 --json reviewDecision,mergeStateStatus,headRefName
gh pr checks $1
```

2. **Identify linked issue** — Read PR body for `Fixes #N` or `Closes #N`.

3. **Merge the PR**:

```bash
gh pr merge $1 --merge --delete-branch
```

4. **Clean up issue labels**:

```bash
gh issue edit <N> --remove-label "status:needs-review"
```

5. **Clean up local branch**:

```bash
git checkout main && git pull && git branch -d <branch-name>
```

6. **Report** — Confirm merge and show the PR URL.
