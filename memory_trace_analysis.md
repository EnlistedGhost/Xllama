# Memory Estimation Trace Analysis for gemma3:12b

**Date**: 2025-10-29
**Goal**: Understand why estimated memory (11.9 GiB) exceeds actual usage (10.48 GiB) by 1.42 GiB

## Input Data from Logs

### System Configuration
- GPUs: 2x Tesla K80 (11.2 GiB each)
- Model: gemma3:12b
- Layers: 49 total (48 repeating + 1 output)
- Context: 4096 tokens
- Batch: 512 tokens
- Parallel: 1

### Log Output - Estimated Memory
```
memory.available="[11.1 GiB 11.1 GiB]"
memory.required.full="11.9 GiB"
memory.required.partial="11.9 GiB"
memory.required.kv="736.0 MiB"
memory.required.allocations="[3.3 GiB 8.6 GiB]"
memory.weights.total="6.8 GiB"
memory.weights.repeating="6.0 GiB"
memory.weights.nonrepeating="787.5 MiB"
memory.graph.full="1.3 GiB"
memory.graph.partial="1.3 GiB"
projector.weights="795.9 MiB"
projector.graph="1.0 GiB"
layers.split="1,48"
```

### Log Output - Actual Memory Usage
```
Model weights loaded:
  CPU buffer: 787.5 MiB
  CUDA0 buffer: 136.7 MiB
  CUDA1 buffer: 7.4 GiB
  Total: 8.324 GiB

Compute graphs allocated:
  CUDA0: 85.8 MiB
  CUDA1: 1.1 GiB
  CPU: 7.5 MiB
  Total: 1.193 GiB

nvidia-smi readings:
  GPU0: 617 MiB (0.602 GiB)
  GPU1: 9866 MiB (9.635 GiB)
  Total: 10.237 GiB
```

## Component-by-Component Analysis

### 1. Model Weights
- **Estimated**: 6.8 GiB (memory.weights.total)
- **Actual**: 8.324 GiB (787.5 MiB CPU + 136.7 MiB GPU0 + 7.4 GiB GPU1)
- **Delta**: +1.524 GiB (actual > estimate)
- **Status**: ⚠️ UNDERESTIMATED

**Note**: This is odd - weights are UNDERESTIMATED, not overestimated!

### 2. KV Cache
- **Estimated**: 736 MiB
- **Actual**: Included in nvidia-smi totals, hard to isolate
- **Status**: ❓ UNKNOWN

### 3. Compute Graphs
- **Estimated**: 1.3 GiB (per log: memory.graph.full)
- **Actual**: 1.193 GiB (85.8 MiB GPU0 + 1.1 GiB GPU1)
- **Delta**: -0.107 GiB (slight overestimate)
- **Status**: ✅ CLOSE

### 4. Projector Components
- **Estimated**: 795.9 MiB weights + 1.0 GiB graph = 1.796 GiB
- **Actual**: Unclear from logs (likely included in weights/graph totals)
- **Status**: ❓ POSSIBLY DOUBLE-COUNTED

### 5. GPU Allocations
```
Estimated per GPU:
  GPU0: 3.3 GiB
  GPU1: 8.6 GiB
  Total: 11.9 GiB

Actual per GPU (nvidia-smi):
  GPU0: 0.602 GiB
  GPU1: 9.635 GiB
  Total: 10.237 GiB

Delta:
  GPU0: -2.698 GiB (MASSIVE overestimate)
  GPU1: +1.035 GiB (underestimate)
  Total: -1.663 GiB (net overestimate)
```

## Key Findings

### Finding 1: GPU0 Massive Overestimation
GPU0 estimated at **3.3 GiB** but actually uses only **0.602 GiB**.

**Possible causes:**
1. Full graph allocation assigned to GPU0 during estimation
2. Layer weights estimated for GPU0 but actually loaded elsewhere
3. Conservative buffers that aren't actually needed

### Finding 2: Weights Accounting Mismatch
- Log says `memory.weights.total="6.8 GiB"`
- But actual weight buffers sum to **8.324 GiB**
- **Gap: 1.524 GiB underestimate**

This suggests the `memory.weights.total` in logs **excludes something** (KV cache? buffers?).

### Finding 3: Layer Split Decision
With split `1,48`:
- GPU0: 1 layer only (why?)
- GPU1: 48 layers

If GPU0 can only hold 1 layer, why estimate 3.3 GiB for it?

## Hypothesis: The Root Cause

**Theory**: The layer placement algorithm is placing 1 layer on GPU0 unnecessarily due to:

1. GPU0 gets allocated **full graph overhead** (1.3 GiB) during estimation
2. This leaves ~9.8 GiB "available" on GPU0
3. Algorithm tries to place layers, but only 1 fits after accounting for real overheads
4. This triggers multi-GPU mode
5. But if we **didn't place ANY layers on GPU0**, all 49 layers could fit on GPU1

**Test hypothesis**: What if we disable GPU0 entirely?

## Next Steps

1. **Add debug logging** to track exact layer-by-layer placement decisions
2. **Calculate theoretical single-GPU memory**:
   - All weights on GPU1: 8.324 GiB
   - Full graph on GPU1: 1.3 GiB
   - KV cache: 0.736 GiB
   - Total: ~10.36 GiB
   - **Result**: Fits in 11.2 GiB! ✅

3. **Find why algorithm splits**:
   - Is it the `overhead` value?
   - Is it the layer placement logic at lines 243-277?
   - Is it the graph allocation at lines 230-241?

4. **Possible fixes**:
   - Option A: Be more conservative about GPU0 free space
   - Option B: Prefer single-GPU until proven necessary
   - Option C: Adjust overhead calculations
   - Option D: Fix the layer placement algorithm to try single-GPU first

## Code Sections to Investigate

1. **Line 106**: `overhead := envconfig.GpuOverhead()` - What is this value?
2. **Lines 193-213**: GPU filtering logic - Which GPUs are deemed "viable"?
3. **Lines 230-241**: Graph allocation per GPU - Is GPU0 getting full 1.3 GiB?
4. **Lines 243-277**: Layer placement loop - Why does it place layers on GPU0?
5. **Lines 282-303**: Output layer placement - Does this trigger GPU0 usage?

## Questions to Answer

1. What is `envconfig.GpuOverhead()` returning?
2. What is `gpus[i].MinimumMemory` for each GPU?
3. During layer placement, what are the `used` values for each GPU?
4. What is `gpusWithSpace` after filtering?
5. Is the 190 MiB optimization actually being applied?
