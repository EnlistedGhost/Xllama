Review a pull request. Reference `.claude/skills/review-pr.md` for context.

The user will provide: **$ARGUMENTS** (a PR number)

## Steps

1. **Read the PR**:

```bash
gh pr view $1
gh pr diff $1
```

2. **Check CI status**:

```bash
gh pr checks $1
```

3. **Run review checklist**:

- [ ] PR body contains `Fixes #N` or `Closes #N`
- [ ] Title is clear and under 70 characters
- [ ] Changes match issue acceptance criteria
- [ ] No unnecessary changes
- [ ] No security vulnerabilities
- [ ] Tests added/updated
- [ ] No debug/temporary code

4. **Decision** — Check if you are the PR author (GitHub blocks self-approval):

If NOT the author — approve:
```bash
gh pr review $1 --approve --body "LGTM"
```

If you ARE the author — comment instead:
```bash
gh pr comment $1 --body "Self-review complete. Checklist passes. Ready to merge."
```

Request changes (works for any reviewer):
```bash
gh pr review $1 --request-changes --body "<specific feedback>"
```

5. **Report** — Tell the user the review result and next step (`/merge` if approved).
