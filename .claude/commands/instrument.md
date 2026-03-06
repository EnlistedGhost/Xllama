Add timing instrumentation to measure performance. Reference `.claude/skills/instrument.md` for context.

Ask the user which area to instrument if not specified. Common targets:
- model loading (`load_tensors`, `init_mappings`, `load_all_data`)
- GPU transfer (`ggml_backend_tensor_set` calls)
- inference graph build/execute

## Steps
1. Read the target code section
2. Identify phase boundaries (function calls, loops, branch points)
3. Insert timing code using the `// INSTRUMENT:` comment prefix
4. Use `LLAMA_LOG_INFO` for C/C++ or `slog.Info` for Go
5. Show the user the changes and how to read the output
6. Remind: remove instrumentation after measurement

## C/C++ pattern
```cpp
// INSTRUMENT: measure phase X
auto t_start = std::chrono::high_resolution_clock::now();
// ... code under measurement ...
auto t_end = std::chrono::high_resolution_clock::now();
LLAMA_LOG_INFO("%s: phase X took %.2f ms\n", __func__,
    std::chrono::duration<double, std::milli>(t_end - t_start).count());
```

## Go pattern
```go
// INSTRUMENT: measure phase X
tStart := time.Now()
// ... code under measurement ...
slog.Info("phase X", "elapsed", time.Since(tStart))
```

Do NOT change any logic. Only add timing measurement code.
