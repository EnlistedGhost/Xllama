---
name: evolve
description: Evidence-based self-improvement loop that analyzes GitHub issues, git commits, and session summaries to detect patterns and propose improvements to CLAUDE.md, skills, and commands.
argument-hint: [issues|commits] [--since Nd]
---

# Evolve — Self-Improvement Loop

Analyze project history to detect patterns and suggest improvements to CLAUDE.md, skills, and commands. Use `/evolve` to run.

## When to use
- Periodically (weekly or after 5+ work sessions) to review workflow health
- When friction points keep recurring across sessions
- After a milestone to evaluate what worked and what didn't
- When CLAUDE.md or skills feel out of date with actual practice

## How it works
1. Collects data from GitHub issues, git history, and session summaries
2. Detects patterns: workflow gaps, friction points, usage patterns, knowledge decay
3. Generates confidence-scored insights with evidence citations
4. Evaluates whether prior evolve actions were effective
5. Proposes concrete improvements grouped by category
6. Applies selected actions after user confirmation

## Key references
- Reports saved to: `docs/evolve/[YYYY-MM-DD]_evolve_report.md`
- Session patterns: `docs/session_summaries/patterns.md`
- Prior reports establish baseline for trend tracking
- See `docs/workflows/trace-and-evolve.md` for the full loop design
