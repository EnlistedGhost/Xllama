---
name: create-pr
description: Create a pull request after implementation and tests pass. Use when code is ready for review — pushes branch, opens PR with issue linkage, updates labels. This is the PR CREATED state in the Development Lifecycle.
argument-hint: <issue-number>
---

# Create PR

Push branch and open a pull request that references the GitHub issue. Use `/create-pr` to start.

**Lifecycle state**: PR CREATED → REVIEWING (see Development Lifecycle in CLAUDE.md)

## When to use
- After `/implement` is complete and tests pass
- Code is ready for review

## Workflow

### 1. Verify readiness
- Check that you're on the correct branch (`issue-<N>-<slug>`)
- Confirm tests have passed (if not, go back to `/implement`)
- Run `git status` to check for uncommitted changes

### 2. Push branch
```bash
git push -u origin <branch-name>
```

### 3. Create PR
```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<what was done — 1-3 bullet points>

Fixes #<issue-number>

## Test plan
- [ ] <test checklist items>

Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- Title: short, under 70 characters
- Body: must include `Fixes #N` or `Closes #N` to auto-close the issue
- Copy relevant labels from the issue to the PR

### 4. Update issue
```bash
gh issue edit <N> --remove-label "status:in-progress" --add-label "status:needs-review"
gh issue comment <N> --body "PR #<PR> created. Summary: <what changed>"
```

### 5. Report back
- Show the PR URL to the user
- The next step is `/review-pr`
