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
# Branch name: issue-<number>-<short-slug>
git checkout -b issue-<number>-<slug> main
```

4. **Implement** — Make the changes based on the issue's acceptance criteria.

5. **Add tests** if the change is testable — suggest `/add-test`.

6. **Build and test** — Use `/build` and `/test` or `/ci`.

7. **Create PR**:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<what was done>

Fixes #<issue-number>

## Test plan
- [ ] ...

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
