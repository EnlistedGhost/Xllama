# Trace and Evolve: The Continuous Improvement Loop

This document explains how GitHub issues, session summaries, and the `/evolve` command form a closed-loop system for tracking work and continuously improving the development workflow.

## Overview

The trace-and-evolve loop connects three concerns:

1. **Track** — GitHub issues record what work was done and why
2. **Observe** — Session summaries capture friction points and patterns
3. **Improve** — `/evolve` analyzes all evidence and proposes actionable changes

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    TRACE AND EVOLVE LOOP                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌──────────────┐         ┌──────────────┐         ┌──────────────┐   │
│   │   TRACK      │         │   OBSERVE    │         │   IMPROVE    │   │
│   │              │         │              │         │              │   │
│   │  GitHub      │────────▶│  Session     │────────▶│   /evolve    │   │
│   │  Issues      │         │  Summaries   │         │              │   │
│   │              │         │              │         │              │   │
│   │  /plan       │         │  /session-   │         │  Analyze     │   │
│   │  /implement  │         │   summary    │         │  Propose     │   │
│   │  /create-pr  │         │              │         │  Apply       │   │
│   │  /merge      │         │  patterns.md │         │              │   │
│   └──────┬───────┘         └──────────────┘         └──────┬───────┘   │
│          │                                                  │           │
│          │              ┌──────────────┐                    │           │
│          │              │   EXECUTE    │                    │           │
│          └─────────────▶│              │◀───────────────────┘           │
│                         │  Dev Work    │                                │
│                         │  (skills &   │                                │
│                         │   commands)  │                                │
│                         └──────────────┘                                │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## The Three Layers

### Layer 1: Track — GitHub Issue Lifecycle

GitHub issues provide the traceability layer. The development lifecycle state machine (see CLAUDE.md) tracks every piece of work from request through merge.

```
/plan "Add support for new model architecture"
    │
    │  Creates GitHub issue(s) with labels and project board entry
    │
    ▼
/implement 42
    │
    │  Creates branch, starts coding
    │  Comments progress on the issue
    │
    ▼
/create-pr
    │
    │  Opens PR with "Fixes #42"
    │
    ▼
/merge
    │
    │  Merges PR, issue auto-closes
    │  Full audit trail preserved
    ▼
  Done
```

### Layer 2: Observe — Session Summaries

Session summaries capture what happened during each working session without exposing sensitive data.

```
/session-summary
    │
    ├─► Collects: goal, commands used, artifacts produced,
    │             friction points, workflow pattern, outcome
    │
    ├─► Privacy check: strips sensitive data
    │
    ├─► Saves to: docs/session_summaries/YYYY-MM-DD_HHMM_summary.md
    │
    └─► Updates:  docs/session_summaries/patterns.md
                  (aggregates friction points, improvement candidates)
```

The `patterns.md` file acts as a bridge between session-level observations and project-level analysis:

| Section | What It Captures | Consumed By |
|---------|-----------------|-------------|
| Workflow Distribution | Which phases are used most | `/evolve` Phase 1 |
| Recurring Friction Points | Problems seen 2+ times | `/evolve` Phase 2 (3+ = High confidence) |
| Improvement Candidates | Suggested fixes from sessions | `/evolve` Phase 5 |

### Layer 3: Improve — `/evolve` Analysis

`/evolve` is the analytical engine. It reads GitHub issues, git history, and session summaries, then proposes evidence-based improvements.

```
/evolve
    │
    ├─► Phase 0: Read prior evolve reports (baseline)
    │
    ├─► Phase 1: Data Collection
    │   ├── GitHub issues (gh issue list)
    │   ├── Git commits (git log)
    │   ├── File change patterns (git log --name-only)
    │   └── Session summaries (patterns.md)
    │
    ├─► Phase 2: Pattern Detection
    │   ├── Workflow Gaps — missing automation
    │   ├── Friction Points — recurring fixes/reverts
    │   ├── Usage Patterns — co-changed files, churn
    │   └── Knowledge Decay — stale docs
    │
    ├─► Phase 3: Generate Insights (Low / Medium / High confidence)
    │
    ├─► Phase 4: Evaluate Prior Actions (did previous fixes work?)
    │
    ├─► Phase 5: Propose Actions
    │   ├── CLAUDE.md updates
    │   ├── New or updated commands
    │   ├── Skill improvements
    │   └── Memory updates
    │
    ├─► Phase 6: Output Report → docs/evolve/YYYY-MM-DD_evolve_report.md
    │
    └─► Phase 7: Apply (with user confirmation)
```

## How the Loop Closes

The three layers feed into each other, creating a continuous improvement cycle:

```
                    ┌──────────────────────────────────┐
                    │         DEV WORK SESSION          │
                    │                                    │
                    │  /implement                        │
                    │  /build                            │
                    │  /test            ◄────────────────┼─── Improved commands
                    │  /trace                            │    and workflows
                    │  /debug                            │
                    └──────────┬───────────────────┬────┘
                               │                   │
                    ┌──────────▼──────┐  ┌────────▼────────┐
                    │  GitHub Issues  │  │ /session-summary │
                    │                 │  │                  │
                    │  What was done  │  │  What was hard   │
                    │  Why it matters │  │  What was slow   │
                    │  What remains   │  │  What worked     │
                    └──────────┬──────┘  └────────┬────────┘
                               │                   │
                               └─────────┬─────────┘
                                         │
                               ┌─────────▼─────────┐
                               │     /evolve        │
                               │                    │
                               │  Analyze evidence  │
                               │  Detect patterns   │
                               │  Propose actions   │
                               │  Track outcomes    │
                               └─────────┬─────────┘
                                         │
                               ┌─────────▼─────────┐
                               │  Applied Changes   │
                               │                    │
                               │  • CLAUDE.md rules │
                               │  • New commands    │
                               │  • Updated skills  │
                               │  • Better docs     │
                               └─────────┬─────────┘
                                         │
                                         └──────────────────► Next session
```

**Cycle frequency:**
- GitHub issues — every task (via development lifecycle)
- `/session-summary` — end of each session
- `/evolve` — periodically (e.g., weekly or after 5+ sessions)

## Data Flow Summary

| Source | Data | Destination | Purpose |
|--------|------|-------------|---------|
| Dev work | Code changes, artifacts | GitHub issues | Traceability |
| GitHub issues | Issue history (state, labels, comments) | `/evolve` Phase 1 | Evidence |
| Git log | Commit messages, file changes | `/evolve` Phase 1 | Evidence |
| `/session-summary` | Aggregated patterns | `patterns.md` | Pattern storage |
| `patterns.md` | Friction points, candidates | `/evolve` Phase 1 | Evidence |
| `/evolve` | Proposed actions | CLAUDE.md, commands, skills | Improvement |
| `/evolve` | Report | `docs/evolve/` | Baseline for next run |

## Getting Started

### During work: Track via development lifecycle

The existing state machine (`/plan` → `/implement` → `/test` → `/create-pr` → `/review-pr` → `/merge`) already tracks work in GitHub issues.

### At end of session: Observe

```
/session-summary                    # Record session patterns
```

### Periodically: Analyze and improve

```
/evolve                             # Full analysis (issues + commits, 90 days)
/evolve --since 30d                 # Shorter window
/session-summary review             # Review accumulated patterns
```

## Related Commands

| Command | Purpose |
|---------|---------|
| `/plan` | Create GitHub issues for planned work |
| `/implement` | Start work on an issue |
| `/create-pr` | Push branch, open PR |
| `/merge` | Merge PR, cleanup |
| `/session-summary` | Record privacy-safe session summary |
| `/evolve` | Analyze history and propose improvements |
