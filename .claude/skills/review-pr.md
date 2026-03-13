---
name: review-pr
description: Review a pull request using a structured checklist. Use when a PR is open and needs review — checks code quality, test coverage, issue linkage. This is the REVIEWING state in the Development Lifecycle.
argument-hint: <pr-number>
---

# Review PR

Review a pull request against a structured checklist. Use `/review-pr` to start.

**Lifecycle state**: REVIEWING → MERGED or → IMPLEMENTING (see Development Lifecycle in CLAUDE.md)

## When to use
- After `/create-pr` has opened a PR
- When a PR needs review before merging

## Review Checklist

### 1. Issue linkage
- [ ] PR body contains `Fixes #N` or `Closes #N`
- [ ] PR title is clear and under 70 characters
- [ ] Labels match the linked issue

### 2. Code quality
- [ ] Changes match the issue's acceptance criteria
- [ ] No unnecessary changes beyond what was requested
- [ ] No security vulnerabilities (injection, hardcoded secrets, etc.)
- [ ] No debug/temporary code left in

### 3. Test coverage
- [ ] Relevant tests added or updated
- [ ] Tests pass locally (`/test`)
- [ ] CI checks pass (if applicable)

### 4. Documentation
- [ ] Comments added where logic isn't self-evident
- [ ] No unnecessary comments or docstrings

### 5. Decision
- **Approve**: All checks pass → proceed to `/merge`
- **Request changes**: Comment on PR with specific feedback → back to `/implement`
  ```bash
  gh pr review <PR> --comment --body "Changes requested: <feedback>"
  ```

## Workflow

```bash
# View PR details
gh pr view <PR>

# View the diff
gh pr diff <PR>

# Check CI status
gh pr checks <PR>

# Approve
gh pr review <PR> --approve --body "LGTM"

# Or request changes
gh pr review <PR> --request-changes --body "<feedback>"
```
