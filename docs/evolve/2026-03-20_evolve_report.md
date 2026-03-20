# Evolve Report — 2026-03-20

## Summary
- Time range analyzed: 90 days (2025-12-20 to 2026-03-20)
- Issues analyzed: 27
- Commits analyzed: 63
- Insights found: 10 (High: 4, Medium: 3, Low: 3)
- Prior report: First run

## High-Confidence Insights

### 1. Friction Point: Qwen3.5 DeltaNet required heavy iterative fixing
- **Evidence:** `fc27bff1`, `4ac9a799`, `65d00908`, `5d161642`, `13b1d9df`, `6ab7a678`, `b99f0457`, `ee6806f1`, `06604dc4`, `f57d0208`, `cac19af8`, `9b075807` (12 fix commits in `llama-model.cpp`)
- **Confidence:** High
- **Category:** Friction Point
- **Suggestion:** Expected for new architecture porting. Root cause captured in project memory ("Critical Lessons"). No action needed — pattern self-corrected.

### 2. Usage Pattern: CLAUDE.md is the highest-churn file
- **Evidence:** `75495290`, `40fdb772`, `3cb598c0`, `d40d3287`, `c917b07e`, `c41f84e5`, `20fc2112` + 3 more (10+ commits)
- **Confidence:** High
- **Category:** Usage Pattern
- **Suggestion:** Stabilizing — recent edits are structural additions, not corrections. Monitor: if churn continues, consider splitting into topic files.

### 3. Usage Pattern: CI test framework is the most actively developed subsystem
- **Evidence:** #32, #34, #36, `e7084388`, `72561883`, `2283dfe4`, `17e87f52`, `0f866e75` (5 commits to `llm-judge.ts`), 15 YAML test cases
- **Confidence:** High
- **Category:** Usage Pattern
- **Suggestion:** Consider a `/judge` debug command for testing LLM judge in isolation.

### 4. Usage Pattern: Skills and commands co-evolve in batches
- **Evidence:** `c917b07e` (12 files), `20fc2112` (7 files), `75495290` (10 files), `ebc4803d`, `40fdb772`
- **Confidence:** High
- **Category:** Usage Pattern
- **Suggestion:** Healthy pattern — batch updates keep skills consistent. No action needed.

## Medium-Confidence Insights

### 5. Workflow Gap: Issue #39 is the only open issue, stale for 7 days
- **Evidence:** #39 (open since 2026-03-13, zero comments, no activity)
- **Confidence:** Medium
- **Category:** Workflow Gap
- **Suggestion:** Triage — close if covered by #43, or add status label.

### 6. Friction Point: Old community issues lacked labels
- **Evidence:** #8, #7, #6, #4, #3 (all closed, no labels)
- **Confidence:** Medium
- **Category:** Friction Point
- **Suggestion:** Retroactively label for cleaner future analysis.

### 7. Knowledge Decay: Early directory-format skills may have remnants
- **Evidence:** `4f79621e` touched `.claude/skills/build/SKILL.md`, then `c41f84e5` restructured to flat files
- **Confidence:** Medium
- **Category:** Knowledge Decay
- **Suggestion:** Verify no old directories remain. **Verified clean — no remnants found.**

## Low-Confidence Observations

### 8. Usage Pattern: docs/traces/ has 3 files, all Qwen3.5-related
- **Evidence:** `qwen35-garbage-output.md`, `qwen35-deltanet-rewrite-plan.md`, `qwen35-reshape-assert.md`
- **Suggestion:** Good reference material. Structure is fine for now.

### 9. Workflow Gap: No /session-summary was ever run organically
- **Evidence:** patterns.md shows 1 retroactively recorded session
- **Suggestion:** Consider end-of-session reminder hook.

### 10. Usage Pattern: Anthropic API compatibility code untouched since initial implementation
- **Evidence:** `b5dd147d`, `dbf95859` (early commits, no follow-up)
- **Suggestion:** Monitor — may need updating if Claude Code API requirements change.

## Proposed Actions

| # | Action | Category | Priority | Effort | Risk | Status |
|---|--------|----------|----------|--------|------|--------|
| 1 | Add Trace-and-Evolve workflow section to CLAUDE.md | CLAUDE.md Update | Important | Small | None | **Applied** |
| 2 | Consider `/judge` debug command for LLM judge testing | New Command | Nice-to-have | Medium | None | **Deferred** |
| 3 | Verify and clean up old directory-format skill remnants | Skill Cleanup | Important | Small | None | **Verified clean** |
| 4 | Triage issue #39 — comment and add visibility | Project Cleanup | Important | Small | None | **Applied** |
| 5 | Retroactively label old issues #3, #4, #6, #7, #8 | Project Cleanup | Nice-to-have | Small | None | **Applied** |

## Patterns to Monitor

| Pattern | What to Check | Success Criteria |
|---------|--------------|------------------|
| CLAUDE.md churn | Count CLAUDE.md edits per session | ≤1 edit per session (stabilizing) |
| LLM judge stability | Fix commits touching `llm-judge.ts` | Zero fix commits in next 30 days |
| Session summary adoption | Count of summaries in `docs/session_summaries/` | ≥3 summaries in next 30 days |
| Open issue staleness | Any open issue with no activity >14 days | Zero stale open issues |
| Anthropic API drift | Changes to Claude Code API requirements | Update `anthropic/` if needed |
