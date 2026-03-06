Show profiling commands for the user's scenario. Reference `.claude/skills/profile.md` for context.

Ask what they want to profile if not specified:
- **cpu** — perf record/report commands
- **syscalls** — strace commands for I/O and mmap analysis
- **gpu** — nvprof commands for CUDA operations
- **memory** — page fault and RSS analysis
- **io** — disk throughput during loading

For each scenario, show the exact command, what to look for, and how to interpret results.

## CPU profiling
```bash
# Call graph sampling
perf record -g ./ollama serve &
sleep 10 && ./ollama run <model> "hello" && pkill ollama
perf report

# Hardware counter summary
perf stat ./ollama serve
```

## Syscall tracing
```bash
# Timing per syscall
strace -T -e trace=read,write,mmap,madvise ./ollama serve

# Syscall count summary
strace -c ./ollama serve

# Attach to running process
strace -T -e trace=read,mmap,madvise -p $(pgrep ollama) 2>&1 | head -200
```
Look for: slow `read()` calls, excessive `mmap`/`munmap`, page fault patterns.

## GPU profiling (CUDA 11.4)
```bash
# CUDA kernel and memcpy timing
nvprof ./ollama serve 2>&1 | tee /tmp/nvprof.log &
sleep 5 && ./ollama run <model> "hello" && pkill ollama

# Per-operation GPU trace
nvprof --print-gpu-trace ./ollama serve
```
Look for: `cudaMemcpy` duration/count, kernel launch overhead, sync stalls.
Note: use `nvprof` not `nsys` — nsys requires newer driver than 470.

## Memory profiling
```bash
# Page fault counts
perf stat -e page-faults,major-faults,minor-faults ./ollama serve

# Watch swap and I/O wait during loading
vmstat 1

# Check RSS vs mapped memory
cat /proc/$(pgrep ollama)/smaps | grep -E '^(Size|Rss|Pss)' | head -30
```

## I/O profiling
```bash
# Disk utilization and throughput
iostat -x 1

# Per-process I/O bandwidth
iotop -p $(pgrep ollama)
```
