---
name: trace
description: Trace a code path to understand execution flow. Use before modifying unfamiliar code or investigating unexpected behavior.
---

# Trace

Follow one execution path through the code, documenting the call chain and branch decisions. Use `/trace` to perform.

## When to use
- Investigating how a feature works before modifying it
- Understanding which code path is actually taken at runtime
- Before making performance changes — know the current flow first
- When log output shows unexpected behavior

## Rules
- **One path at a time** — don't try to understand the whole codebase
- **Start from the log message** — grep for the log string, work outward
- **Note branch conditions** — document which `if` branch is taken and why
- **Verify with runtime** — reading code shows what *could* happen; logging/debugger shows what *does* happen
- **Record the trace** — output a call-flow summary when done

## Call-flow summary format
```
function_a()                          # file.cpp:123
  ├── function_b()                    # file.cpp:456 — condition: use_mmap
  │   ├── leaf_operation()            # other.cpp:78 — fast path, no copy
  │   └── slow_operation()            # other.cpp:92 — sync cudaMemcpy
  └── function_c()                    # file.cpp:500 — condition: !use_mmap
      └── async_operation()           # other.cpp:110 — staged upload
```

## Where to save traces
- `docs/traces/` directory — one markdown file per traced path
- Name by feature: `model-loading.md`, `kv-cache-init.md`, `gpu-offload.md`
