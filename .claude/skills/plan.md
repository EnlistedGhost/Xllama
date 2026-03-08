---
name: plan
description: Break down feature requests into GitHub Issues with labels, priorities, and project board tracking. Use when the user describes a feature, enhancement, removal, or bug to plan and track.
---

# Plan

Break down work into GitHub Issues with proper labels, priority, and project board tracking. Use `/plan` to start.

## When to use
- User describes a feature, enhancement, or removal request
- User wants to plan or organize work
- User reports a bug

## Labels

### Type labels (required — one per issue)

| Action | Label |
|--------|-------|
| New capability | `feature` |
| Improve existing | `enhancement` |
| Remove something | `removal` |
| Bug report | `bug` |

### Priority labels (required — one per issue)

| Priority | Label | When to use |
|----------|-------|-------------|
| Critical | `priority:critical` | Blocks release, data loss, security |
| High | `priority:high` | Important, fix soon |
| Medium | `priority:medium` | Normal priority (default) |
| Low | `priority:low` | Nice to have |

### Component labels (add all that apply)

| Component | Label |
|-----------|-------|
| GGML ops/backends | `component:ggml` |
| CUDA kernels/GPU | `component:cuda` |
| Model loading/graph | `component:model` |
| Go code (server, renderer) | `component:go` |
| CI/CD and testing | `component:ci` |

## Workflow

1. **Check existing issues** — `gh issue list` to avoid duplicates
2. **Classify** the request (type + priority + components)
3. **Break down** into individual issues if needed
4. **Create issues** with labels:
   ```bash
   gh issue create \
     --label "feature" --label "priority:medium" --label "component:cuda" \
     --title "<title>" --body "<body>"
   ```
5. **Link related issues** — mention dependencies in the body: `Depends on #N`, `Blocked by #N`
6. **Add to project board**:
   ```bash
   gh project item-add 2 --owner dogkeeper886 --url <issue-url>
   ```
7. **Summarize** — output a table of created issues

## Issue body templates

### Feature
```
## User Story
As a [role], I want [capability], so that [benefit].

## Acceptance Criteria
1. ...

## Technical Notes
- ...

## Dependencies
- None | Depends on #N
```

### Bug
```
## Description
...

## Expected Behavior
...

## Steps to Reproduce
1. ...
```

## Issue tracking
- After creating issues, confirm the issue numbers with the user
- When revisiting a plan, check existing issues for updates before creating duplicates
- Use `gh issue list` and `gh issue view <number>` to check current state
