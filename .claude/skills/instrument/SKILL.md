---
name: instrument
description: Add timing instrumentation to measure where time is spent. Use when investigating slow loading, GPU transfer, or unexplained latency.
---

# Instrument

Add temporary timing code around suspected slow sections. Produces hard data instead of guesses. Use `/instrument` to apply.

## When to use
- A phase takes unexpectedly long (e.g. model loading, GPU transfer)
- You suspect waste but cannot confirm without measurement
- Before making any performance optimization
- After an optimization to verify improvement

## Rules
- **Measure first, optimize second** — never optimize based on assumption
- **Use existing logging** — llama.cpp has `LLAMA_LOG_INFO`/`LLAMA_LOG_DEBUG`, Go has `slog`
- **Mark instrumentation clearly** — use `// INSTRUMENT:` comment prefix so it's easy to find and remove
- **Keep instrumentation minimal** — measure boundaries, not every line
- **Remove after confirming** — instrumentation is temporary, not permanent

## Key locations for model loading
- `llama_model_loader::init_mappings` — mmap setup and prefetch
- Buffer allocation loop in `load_tensors` — VRAM allocation
- `llama_model_loader::load_all_data` — actual tensor data transfer
- Per-tensor `ggml_backend_tensor_set` — individual GPU uploads
