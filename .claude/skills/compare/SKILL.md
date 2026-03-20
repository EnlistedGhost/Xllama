---
name: compare
description: Compare shared components (commands, skills, test framework, docs) between the current repo and a remote repo by reading both repos and using AI judgment to detect drift and propose backport issues.
argument-hint: <remote-repo-path> [--issue]
---

# Compare — Cross-Repo Drift Detection

Compare shared components between the current repo and a remote repo. Use `/compare` to run.

## When to use
- Before backporting improvements to another repo
- After porting a feature from another repo to check what else diverged
- Periodically to detect drift between repos that share components
- When the user mentions syncing, backporting, or comparing repos

## How it works
1. Reads CLAUDE.md, skills, commands, and key files in BOTH repos
2. Uses AI judgment to identify components that serve the same purpose (not just same filename)
3. Diffs matched components, distinguishing meaningful improvements from project-specific adaptations
4. Generates a structured comparison report
5. Optionally creates GitHub issues in the remote repo for backport items (--issue flag)

## Key design principle
No manifest file — the AI agent determines what's shared by understanding both repos' purpose, structure, and conventions. Two files with different names/paths but the same intent ARE the same component.
