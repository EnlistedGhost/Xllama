---
name: session-summary
description: Record a privacy-safe summary of the current session to feed pattern detection and the /evolve self-improvement loop.
argument-hint: [--detail full | review]
---

# Session Summary — Privacy-Safe Session Recorder

Generate a privacy-safe summary of the current session to feed pattern detection and workflow improvement. Use `/session-summary` to run.

## When to use
- At the end of a work session to capture friction points and patterns
- Before closing out a multi-step task to record what worked
- With `review` argument to see aggregated patterns across sessions

## How it works
1. Collects session context: goal, commands used, artifacts, friction points
2. Classifies the workflow pattern and outcome
3. Generates an anonymized summary for user approval
4. Saves to `docs/session_summaries/` and updates `patterns.md`

## Key references
- Summaries saved to: `docs/session_summaries/[YYYY-MM-DD]_[HHMM]_summary.md`
- Aggregated patterns: `docs/session_summaries/patterns.md`
- Consumed by `/evolve` Phase 1 (Data Collection)
