Break down the user's request into GitHub Issues. Reference `.claude/skills/plan.md` for context.

The user will provide: **$ARGUMENTS**

## Steps

1. **Classify** — Determine action type: feature, enhancement, removal, or bug.
2. **Break down** — Split into individual issues if the request covers multiple items.
3. **Create issues** — Use `gh issue create` for each item:

```bash
# New feature
gh issue create --label "feature" --title "<title>" --body "$(cat <<'EOF'
## User Story
As a [role], I want [capability], so that [benefit].

## Acceptance Criteria
1. ...

## Technical Notes
- ...

## Dependencies
- None
EOF
)"

# Enhancement
gh issue create --label "enhancement" --title "<title>" --body "$(cat <<'EOF'
## Current Behavior
...

## Proposed Change
...

## Acceptance Criteria
1. ...
EOF
)"

# Removal
gh issue create --label "removal" --title "<title>" --body "$(cat <<'EOF'
## What to Remove
...

## Reason
...

## Impact
...
EOF
)"

# Bug
gh issue create --label "bug" --title "<title>" --body "$(cat <<'EOF'
## Description
...

## Expected Behavior
...

## Steps to Reproduce
1. ...
EOF
)"
```

4. **Summarise** — Output a table:

```
| Issue | Title | Type | URL |
|-------|-------|------|-----|
| #N    | ...   | ...  | ... |
```
