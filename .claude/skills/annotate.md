---
name: annotate
description: Add verified comments and architecture docs. Use after confirming behavior through tracing, profiling, or debugging.
---

# Annotate

Add comments and architecture docs tied to verified observations. Use `/annotate` to apply.

## When to use
- After tracing a code path and confirming behavior
- After profiling reveals what a section actually does
- After debugging confirms why code behaves a certain way
- When existing comments are wrong or misleading

## Rules
- **Only annotate verified behavior** — mark assumptions vs facts
- **Comment the "why", not the "what"** — the code already says what it does
- **Use evidence tags** in comments:
  - `// VERIFIED:` — confirmed by running/debugging/profiling
  - `// ASSUMPTION:` — believed true but not yet confirmed
  - `// NOTE:` — context that aids understanding
- **Don't bulk-comment** — annotate only code you've actually investigated
- **Architecture docs over inline comments** for cross-function flows

## Output locations
- Inline comments — in the source file, tagged with evidence level
- Architecture docs — `docs/arch/`, one file per subsystem, 50-100 lines max
- Use call-flow diagrams from the `trace` skill

## What NOT to annotate
- Code you only read but didn't run or test
- Obvious operations (`i++`, loop mechanics)
- Temporary or experimental code
- Code you're about to delete or rewrite
