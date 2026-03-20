# Review a Pull Request

```
Review a pull request using a structured checklist.
Reference `.claude/skills/review-pr/SKILL.md` for context.

PR number: $ARGUMENTS

## PURPOSE

Reviews a pull request against a structured checklist covering issue linkage,
code quality, test coverage, and documentation. Approves or requests changes.

---

## WORKFLOW

    /review-pr 30
        │
        ├─► Step 1: Read the PR
        │   - Run: gh pr view <PR>
        │   - Run: gh pr diff <PR>
        │   - Run: gh pr checks <PR>
        │
        ├─► Step 2: Review Checklist
        │
        │   Issue Linkage:
        │   - [ ] PR body contains "Fixes #N" or "Closes #N"
        │   - [ ] PR title is clear and under 70 characters
        │   - [ ] Labels match the linked issue
        │
        │   Code Quality:
        │   - [ ] Changes match the issue's acceptance criteria
        │   - [ ] No unnecessary changes beyond what was requested
        │   - [ ] No security vulnerabilities (injection, hardcoded secrets)
        │   - [ ] No debug/temporary code left in
        │
        │   Test Coverage:
        │   - [ ] Relevant tests added or updated (if applicable)
        │   - [ ] CI checks pass (if applicable)
        │
        │   Documentation:
        │   - [ ] Comments added where logic isn't self-evident
        │   - [ ] No unnecessary comments or docstrings
        │
        ├─► Step 3: Decision
        │   - Approve: all checks pass → proceed to /merge
        │   - Request changes: specific feedback → back to /implement
        │
        └─► Step 4: Submit Review
            - Check if you are the PR author (GitHub blocks self-approval)
            - If NOT the author:
              gh pr review <PR> --approve --body "LGTM"
            - If you ARE the author (self-review):
              gh pr comment <PR> --body "Self-review complete. Checklist passes. Ready to merge."
            - To request changes:
              gh pr review <PR> --request-changes --body "<specific feedback>"

---

## EXAMPLE

    /review-pr 30

**Agent reads PR, runs checklist:**

    $ gh pr view 30
    $ gh pr diff 30
    $ gh pr checks 30

**Checklist result:**

    ✓ Issue linkage — Fixes #27 present
    ✓ Title — "Add release notes generator command" (42 chars)
    ✓ Code quality — Changes match acceptance criteria
    ✓ No security issues
    ✓ Tests — N/A (markdown-only change)

    $ gh pr review 30 --approve --body "LGTM"

**Output:**

    PR #30 approved. Next: /merge 30

---

## API Notes

- Uses `gh` CLI for PR operations
- GitHub blocks self-approval — use comment instead if you authored the PR
- If CI checks are failing, investigate before approving
- Always read the full diff, not just the PR description
```
