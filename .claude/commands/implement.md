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

4. **Comment on the issue**:

```bash
gh issue comment <N> --body "Starting work on branch \`issue-<N>-<slug>\`"
```

5. **Implement** — Make the changes based on the issue's acceptance criteria.

6. **Add tests** if the change is testable — suggest `/add-test`.

7. **Build and test** — Use `/build` and `/test` or `/ci`.

8. **Create PR** with labels from the issue:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<what was done>

Fixes #<issue-number>

## Test plan
- [ ] ...

Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

9. **Update issue status**:

```bash
gh issue edit <N> --add-label "status:needs-review"
```

10. **After merge** — clean up labels:

```bash
gh issue edit <N> --remove-label "status:needs-review"
```
