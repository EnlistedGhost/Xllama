Trace a code path through the codebase. Reference `.claude/skills/trace/SKILL.md` for context.

The user should specify a starting point — a log message, function name, or behavior to trace. If not specified, ask.

## Steps
1. Grep for the starting point (log string, function name)
2. Read the containing function
3. Identify the execution path based on runtime config (mmap, GPU offload, etc.)
4. Follow calls one level at a time, noting branch conditions
5. Stop at leaf operations
6. Output a call-flow summary in the format from the trace skill
7. Save the trace to `docs/traces/<feature>.md`
8. Ask if the user wants to verify any assumptions with instrumentation

Do NOT modify any code. This is a read-only investigation.
