# Implement a GitHub Issue

```
Start work on a GitHub Issue — create branch, implement, and track progress.
Reference `.claude/skills/implement/SKILL.md` for context.

Issue number: $ARGUMENTS

## PURPOSE

Picks up a GitHub Issue and drives it through implementation. Creates a feature
branch, tracks status via labels and comments, handles failures transparently,
and prepares for PR creation when done.

---

## WORKFLOW

    /implement 27
        │
        ├─► Step 1: Understand the Issue
        │   - Run: gh issue view <N>
        │   - Read acceptance criteria, technical notes, dependencies
        │   - Check labels — type and priority should already be set
        │   - Check for linked/blocking issues
        │   - If anything is unclear, ask the user before starting
        │
        ├─► Step 2: Create Branch
        │   - Use the `git-flow` skill to decide branch vs. main
        │   - Branch name: issue-<N>-<short-slug>
        │     Example: issue-27-release-notes
        │   - Run: git checkout -b issue-<N>-<slug> main
        │   - Comment on issue:
        │     gh issue comment <N> --body "Starting work on branch \`issue-<N>-<slug>\`"
        │   - Add status label:
        │     gh issue edit <N> --add-label "status:in-progress"
        │
        ├─► Step 3: Implement
        │   - Make the changes based on acceptance criteria
        │   - Build and test using `/build`, `/test`, or `/ci`
        │   - Consider `/add-test` if the change needs test coverage
        │   - Commit incrementally with clear messages
        │
        ├─► Step 4a: On Success
        │   - Comment on issue:
        │     gh issue comment <N> --body "Implementation complete, tests passing. Ready for PR."
        │   - Proceed to /create-pr
        │
        ├─► Step 4b: On Failure
        │   - Do NOT silently retry — update the issue:
        │     gh issue comment <N> --body "Build/test failure: <what failed, error, root cause>"
        │   - If blocked, add label:
        │     gh issue edit <N> --add-label "status:blocked"
        │   - Investigate, fix, update issue:
        │     gh issue comment <N> --body "Applied fix: <what changed>. Retesting."
        │   - Remove blocked label after unblocking:
        │     gh issue edit <N> --remove-label "status:blocked"
        │   - If stuck after 2-3 attempts, comment blockers and ask the user
        │
        └─► Step 4c: On Partial Fix
            - Comment: what was fixed, what remains, blockers
            - Proceed to /create-pr if the partial fix is independently useful
            - Create follow-up issues for remaining work

---

## ISSUE CROSS-REFERENCES

Use these patterns in issue comments and PR bodies:
- **Parent/child**: "Part of #N" or "Parent: #N"
- **Dependencies**: "Depends on #N", "Blocked by #N"
- **Related**: "Related to #N"

GitHub auto-creates backlinks when issues reference each other.

---

## EXAMPLE

    /implement 27

**Agent reads issue #27, creates branch, implements:**

    $ gh issue view 27
    $ git checkout -b issue-27-release-notes main
    $ gh issue comment 27 --body "Starting work on branch `issue-27-release-notes`"
    $ gh issue edit 27 --add-label "status:in-progress"

    ... (implementation work) ...

    $ gh issue comment 27 --body "Implementation complete, tests passing. Ready for PR."

**Next step:** /create-pr 27

---

## KEY PRINCIPLE

The issue is the single source of truth. Anyone reading it should see the full
history — start, failures, fixes, and resolution.

---

## API Notes

- Uses `gh` CLI for issue operations
- Branch naming convention: `issue-<number>-<short-slug>`
- Always comment on the issue before and after implementation
- Label management: `status:in-progress` while working, `status:blocked` if stuck
```
