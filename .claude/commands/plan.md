Break down the user's request into GitHub Issues. Reference `.claude/skills/plan.md` for context.

The user will provide: **$ARGUMENTS**

## Steps

1. **Check existing issues** — avoid duplicates:

```bash
gh issue list --state all
```

2. **Classify** — Determine type (feature/enhancement/removal/bug), priority, and components.
3. **Break down** — Split into individual issues if the request covers multiple items.
4. **Create issues** with labels:

```bash
gh issue create \
  --label "feature" --label "priority:medium" --label "component:cuda" \
  --title "<title>" --body "$(cat <<'EOF'
## User Story
As a [role], I want [capability], so that [benefit].

## Acceptance Criteria
1. ...

## Technical Notes
- ...

## Dependencies
- None | Depends on #N
EOF
)"
```

5. **Add to project board**:

```bash
gh project item-add 2 --owner dogkeeper886 --url <issue-url>
```

6. **Summarize** — Output a table:

```
| Issue | Title | Type | Priority | URL |
|-------|-------|------|----------|-----|
| #N    | ...   | ...  | ...      | ... |
```
