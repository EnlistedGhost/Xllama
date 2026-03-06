---
name: profile
description: Run system profiling tools to find bottlenecks. Use before reading code to understand a performance issue.
---

# Profile

Use OS and GPU profiling tools to find where time goes without code changes. Use `/profile` to get commands.

## When to use
- Before diving into source code to understand a performance issue
- When instrumentation would be too invasive
- To get a full-system view (syscalls, page faults, GPU transfers)
- To confirm or reject a hypothesis about a bottleneck

## Tool categories
- **CPU** — `perf` for call graphs and hardware counters
- **Syscalls** — `strace` for I/O timing and mmap behavior
- **GPU** — `nvprof` for CUDA memcpy and kernel timing
- **Memory** — page faults, RSS, swap pressure
- **I/O** — disk throughput and utilization

## What to look for
- Slow `read()` or `cudaMemcpy` calls
- Excessive page faults during mmap access
- High I/O wait during model loading
- Many small GPU transfers instead of few large ones

## Environment notes
- CUDA 11.4 / driver 470 — use `nvprof` not `nsys`
- K80 is PCIe Gen3 x16 — real-world ~8-10 GB/s host-to-device
