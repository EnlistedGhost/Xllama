---
name: plan
description: Break down feature requests into GitHub Issues. Use when the user describes a feature, enhancement, removal, or bug to plan and track.
---

# Plan

Break down work into GitHub Issues using the project's issue templates. Use `/plan` to start.

## When to use
- User describes a feature, enhancement, or removal request
- User wants to plan or organize work
- User reports a bug

## Action types

| Action | Template | Label |
|--------|----------|-------|
| New capability | `feature.yml` | `feature` |
| Improve existing | `enhancement.yml` | `enhancement` |
| Remove something | `removal.yml` | `removal` |
| Bug report | `bug.yml` | `bug` |

## Issue templates location
`.github/ISSUE_TEMPLATE/`

## Workflow
1. Classify the request (new / enhance / remove / bug)
2. Break into individual issues if needed
3. Create issues via `gh issue create`
4. Link related issues with dependencies in the description
