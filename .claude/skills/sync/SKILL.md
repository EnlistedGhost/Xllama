---
name: sync
description: Pull shared components from a remote repo into the current repo, adapting them to fit the local project's conventions and structure using AI judgment.
argument-hint: <remote-repo-path> [--dry-run]
---

# Sync — Cross-Repo Component Sync

Pull shared components from a remote repo into the current repo. Use `/sync` to run.

## When to use
- After `/compare` identifies components worth pulling from remote
- When the user asks to sync, pull, or update from another repo
- After a remote repo has improvements that should be adopted locally

## How it works
1. Reads both repos to understand structure and conventions
2. Identifies what the remote has that's worth pulling (new or improved components)
3. Adapts remote content to fit this repo's style, paths, and project-specific values
4. Shows the plan and applies per-component with user confirmation
5. Updates CLAUDE.md if new skills/commands were added

## Key design principle
No manifest file — the AI agent reads both repos and uses judgment to determine what to sync and how to adapt it. Never blindly copies — always adapts to fit the destination repo's conventions.
