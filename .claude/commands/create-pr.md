Create a pull request for the current branch. Reference `.claude/skills/create-pr.md` for context.

The user will provide: **$ARGUMENTS** (an issue number)

## Steps

1. **Check current state**:

```bash
git status
git log --oneline main..HEAD
```

2. **Identify the issue** — If no argument given, infer from branch name (`issue-<N>-*`).

3. **Push branch**:

```bash
git push -u origin $(git branch --show-current)
```

4. **Create PR** with issue linkage:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points>

Fixes #<issue-number>

## Test plan
- [ ] ...

Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

5. **Update issue labels**:

```bash
gh issue edit <N> --remove-label "status:in-progress" --add-label "status:needs-review"
gh issue comment <N> --body "PR #<PR> created. Summary: <what changed>"
```

6. **Report** — Show the PR URL to the user.
