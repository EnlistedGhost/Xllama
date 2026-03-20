Add verified annotations to the codebase. Reference `.claude/skills/annotate/SKILL.md` for context.

The user should specify what to annotate. Options:
- A specific function or code section
- A traced path (from `docs/traces/`)
- A profiling finding

## Steps
1. Read the target code
2. Check if a trace exists in `docs/traces/` for this area
3. Ask the user what was verified and how (profiling, debugging, tracing)
4. Add inline comments using evidence tags:
   - `// VERIFIED:` — confirmed by running/debugging/profiling
   - `// ASSUMPTION:` — believed true but not yet confirmed
   - `// NOTE:` — context that aids understanding
5. If the annotation spans multiple functions, create or update an architecture doc in `docs/arch/`
6. Only annotate what has been verified — flag anything uncertain as `ASSUMPTION:`

## Examples
```cpp
// VERIFIED: with mmap=true, this path does sync cudaMemcpy per tensor (no async)
ggml_backend_tensor_set(cur, data, 0, n_size);

// ASSUMPTION: MADV_WILLNEED prefetch completes before load_all_data starts
auto mapping = std::make_unique<llama_mmap>(file.get(), prefetch ? -1 : 0, is_numa);
```

Do NOT annotate code that hasn't been investigated. Do NOT add comments that just restate the code.
