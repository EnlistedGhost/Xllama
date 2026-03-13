Start work on a GitHub Issue. Reference `.claude/skills/implement.md` for context.

The user will provide: **$ARGUMENTS** (an issue number)

## Steps

1. **Read the issue**:

```bash
gh issue view <issue-number>
```

2. **Decide flow** — Use the `git-flow` skill. If the change needs testing, use branch flow. Otherwise commit on main.

3. **Create branch** (branch flow):

```bash
git checkout -b issue-<number>-<slug> main
```

4. **Comment on the issue and set status**:

```bash
gh issue comment <N> --body "Starting work on branch \`issue-<N>-<slug>\`"
gh issue edit <N> --add-label "status:in-progress"
```

5. **Implement** — Make the changes based on the issue's acceptance criteria.

6. **Add tests** if the change is testable — suggest `/add-test`.

7. **Build and test** — Use `/build` and `/test` or `/ci`.

8. **On success** — Proceed to `/create-pr` to open a pull request.

9. **On failure** — Update the issue:

```bash
gh issue comment <N> --body "Build/test failure: <what failed, error, root cause>"
gh issue edit <N> --add-label "status:blocked"
```

Fix, then retry. Remove `status:blocked` after unblocking.
