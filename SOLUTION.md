# Solution: Fix gemma3:12b Single-GPU Loading on Tesla K80

**Date**: 2025-10-29
**Branch**: `fix-memory-estimation-gemma12b`
**Status**: Root cause identified, solution designed

---

## Problem Summary

**Issue**: gemma3:12b (10.2 GiB actual usage) splits across 2 GPUs despite fitting in single Tesla K80 (11.2 GiB).

**Symptoms**:
- Estimated memory: 11.9 GiB (split 1,48 layers)
- Actual memory: 10.2 GiB (fits in single GPU!)
- Overestimation: 1.7 GiB

---

## Root Cause Analysis

### Discovery from Debug Logs

The memory estimation function runs **4 times** with different GPU configurations:

1. **Estimation 1 & 2**: Single GPU (GPU 0)
   - Result: `used="8.5 GiB" required="8.6 GiB" fits=true`
   - **All 48 layers fit!** ✅

2. **Estimation 3 & 4**: Multi-GPU (GPU 0 + GPU 1)
   - Result: Split 1,48 layers
   - `memory.required.allocations="[3.3 GiB 8.6 GiB]"` = 11.9 GiB total

### The Real Problem

**Location**: `server/sched.go` lines 865-891

**Logic Flow**:
```go
// Line 865-877: Try single GPU first
for _, g := range sgl {
    if ok, estimatedVRAM = llm.PredictServerFit([]discover.GpuInfo{g}, ...) {
        return []discover.GpuInfo{g}  // ← Should succeed here!
    }
}

// Line 883-891: Fall back to multi-GPU
if ok, estimatedVRAM = llm.PredictServerFit(sgl, ...) {
    return sgl  // ← But returns multi-GPU instead!
}
```

**Why Single-GPU Check Fails**:

The single-GPU check at line 870 calls `PredictServerFit([GPU 0], ...)` which:
1. Calls `EstimateGPULayers([GPU 0], ...)`
2. Gets estimate with `is_multi_gpu=false`, `graph_alloc="1.3 GiB"`
3. Used: 8.5 GiB + overhead
4. Checks: `8.6 GiB < 11.1 GiB` ✅ **Fits!**
5. But `PredictServerFit` **still returns false**!

### The Bug

Looking at `llm/memory.go:18-36` (`PredictServerFit`):

```go
func PredictServerFit(...) (bool, uint64) {
    for _, gpus := range allGpus.ByLibrary() {
        estimate := EstimateGPULayers(gpus, f, projectors, opts, numParallel)
        layerCount, estimatedVRAM = estimate.Layers, estimate.VRAMSize
        if opts.NumGPU < 0 {
            if layerCount > 0 && layerCount >= int(f.KV().BlockCount()+1) {
                return true, estimatedVRAM  // ← Needs 49 layers
            }
        }
    }
    return false, estimatedVRAM
}
```

**The issue**: `f.KV().BlockCount()` returns **48** (repeating layers), so it checks for **49 layers** (48 + 1 output).

But from the debug logs:
```
total_layers=48
```

The estimate only counts **48 layers**, NOT 49! So the check `layerCount >= 49` **fails**, even though all layers actually fit!

---

## Solution Options

### Option A: Fix Layer Count (Safest)

**File**: `llm/memory.go`
**Lines**: Around 282-303 (output layer handling)

**Issue**: The output layer is being handled separately but may not be counted in `layerCount`.

**Fix**: Ensure output layer is included in the layer count.

### Option B: Adjust Comparison Logic

**File**: `llm/memory.go` line 26

**Change**:
```go
// Before:
if layerCount > 0 && layerCount >= int(f.KV().BlockCount()+1) {

// After (if output layer not in BlockCount):
if layerCount > 0 && layerCount >= int(f.KV().BlockCount()) {
```

### Option C: Fix EstimateGPULayers to Always Count Output

**Most robust**: Ensure the layer count explicitly includes the output layer when it's successfully placed.

---

## Recommended Solution

**Approach**: Option A + C (Fix both the counting and verification)

### Step 1: Verify Output Layer Counting

Check if output layer placement increments `layerCount`:

```go
// Around line 282-303 in memory.go
if memoryLastLayer > 0 {
    // ... placement logic ...
    gpuAllocations[g.i] += memoryLastLayer
    layerCounts[g.i]++  // ← Does this happen?
    layerCount++         // ← Does this happen?
}
```

### Step 2: Adjust Comparison if Needed

If output layer is NOT in `BlockCount()`, adjust the comparison at line 26:

```go
// Check against BlockCount() only (48 layers)
if layerCount > 0 && layerCount >= int(f.KV().BlockCount()) {
    return true, estimatedVRAM
}
```

---

## Testing Plan

1. **Verify current behavior**:
   - Add logging to show `f.KV().BlockCount()` value
   - Add logging to show `layerCount` from estimate
   - Add logging in output layer placement to see if it increments count

2. **Apply fix**

3. **Test gemma3:12b**:
   - Should load on single GPU
   - Should show `layers.split=""` (no split)
   - Should use ~10.2 GiB on single GPU

4. **Regression test**:
   - Test gemma3:4b (should still work)
   - Test larger models that NEED multi-GPU

---

## Expected Results

**After fix**:
```
Single-GPU check succeeds:
  PredictServerFit([GPU 0], ...) returns true
  Scheduler selects single GPU
  Model loads on GPU 1 only (preferred by reverse-order logic)

nvidia-smi shows:
  GPU 0: ~3 MiB (minimal Xorg)
  GPU 1: ~10.2 GiB (full model)
```

**Performance improvement**:
- No cross-GPU communication overhead
- Faster inference
- Simpler memory management

---

## Next Steps

1. Add more detailed logging to confirm output layer counting
2. Implement the fix
3. Test and verify
4. Clean up debug logging before merging
5. Update documentation

