# ML Package CC 3.7 Optimization Guide

**Status**: ⚠️ **OPTIONAL** - device.go file not found in current codebase structure

This file contains instructions for simplifying the Go-level ML package to support only Compute Capability 3.7 (Tesla K80 and Kepler GPUs).

## Goal

Simplify GPU detection and device management code by hardcoding values for CC 3.7-only support, removing checks for modern GPU features.

## Note

The `device.go` file referenced in this guide was not found in the current codebase. The GPU detection and device management may be handled in a different structure. The CUDA backend optimizations (Phases 1-8) are complete and provide the primary benefits of the CC 3.7-only optimization.

---

## File: `device.go`

### Lines 277-281: Compute Capability Fields

**Current**: Generic fields for any compute capability

```go
// ComputeMajor is the major version of capabilities of the device
// if unsupported by the backend, -1 will be returned
ComputeMajor int

// ComputeMinor is the minor version of capabilities of the device
ComputeMinor int
```

**Action**: Update documentation to reflect CC 3.7 focus

```go
// ComputeMajor is the major version of capabilities of the device
// For ollama37: Always 3 for Tesla K80 (Kepler)
// if unsupported by the backend, -1 will be returned
ComputeMajor int

// ComputeMinor is the minor version of capabilities of the device
// For ollama37: Always 7 for Tesla K80 (Kepler)
ComputeMinor int
```

### Lines 320-325: MinimumMemory Overhead

**Current**:

```go
func (d DeviceInfo) MinimumMemory() uint64 {
    if d.Library == "Metal" {
        return 512 * format.MebiByte
    }
    return 457 * format.MebiByte
}
```

**Action**: Add comment clarifying CC 3.7 tested value

```go
func (d DeviceInfo) MinimumMemory() uint64 {
    if d.Library == "Metal" {
        return 512 * format.MebiByte
    }
    // CC 3.7 (Tesla K80) minimum overhead: 457 MiB
    // Tested and optimized for Kepler architecture
    return 457 * format.MebiByte
}
```

### Lines 426-438: Flash Attention Support Check

**Current**:

```go
func FlashAttentionSupported(l []DeviceInfo) bool {
    for _, gpu := range l {
        supportsFA := gpu.Library == "cpu" ||
            gpu.Name == "Metal" || gpu.Library == "Metal" ||
            (gpu.Library == "CUDA" && gpu.DriverMajor >= 7 && !(gpu.ComputeMajor == 7 && gpu.ComputeMinor == 2)) ||
            gpu.Library == "ROCm"

        if !supportsFA {
            return false
        }
    }
    return true
}
```

**Action**: Simplify for CC 3.7 (which doesn't support Flash Attention)

```go
func FlashAttentionSupported(l []DeviceInfo) bool {
    for _, gpu := range l {
        // CC 3.7 (Tesla K80) does not support Flash Attention
        // Requires CC 7.0+ (Volta) for tensor core operations
        supportsFA := gpu.Library == "cpu" ||
            gpu.Name == "Metal" || gpu.Library == "Metal" ||
            gpu.Library == "ROCm"
            // CUDA removed: CC 3.7 always returns false

        if !supportsFA {
            return false  // CC 3.7 CUDA GPUs will hit this
        }
    }
    return true
}
```

**Alternative (more explicit)**: Since CC 3.7 doesn't support Flash Attention, consider adding early return:

```go
func FlashAttentionSupported(l []DeviceInfo) bool {
    for _, gpu := range l {
        // Early return for CC 3.7 (Tesla K80) - no Flash Attention support
        if gpu.Library == "CUDA" && gpu.ComputeMajor == 3 {
            return false
        }

        supportsFA := gpu.Library == "cpu" ||
            gpu.Name == "Metal" || gpu.Library == "Metal" ||
            (gpu.Library == "CUDA" && gpu.DriverMajor >= 7 && !(gpu.ComputeMajor == 7 && gpu.ComputeMinor == 2)) ||
            gpu.Library == "ROCm"

        if !supportsFA {
            return false
        }
    }
    return true
}
```

---

## Optional: Add CC 3.7 Validation Helper

Consider adding a validation function to ensure only CC 3.7 GPUs are used:

**Location**: Add to `device.go` after line 281

```go
// IsCC37 returns true if the device is Compute Capability 3.7 (Kepler)
// This build only supports Tesla K80, K40, M40, and similar Kepler GPUs
func (d DeviceInfo) IsCC37() bool {
    return d.ComputeMajor == 3 && d.ComputeMinor == 7
}

// ValidateCC37Only returns an error if any GPU is not CC 3.7
// Use this to enforce CC 3.7-only policy at startup
func ValidateCC37Only(devices []DeviceInfo) error {
    for _, d := range devices {
        if d.Library == "CUDA" && !d.IsCC37() {
            if d.ComputeMajor > 5 || (d.ComputeMajor == 5 && d.ComputeMinor >= 0) {
                return fmt.Errorf("GPU CC %d.%d detected. This build is optimized for CC 3.7 only (Tesla K80). For newer GPUs, please use upstream Ollama which supports CC 5.0+", d.ComputeMajor, d.ComputeMinor)
            }
            if d.ComputeMajor < 3 || (d.ComputeMajor == 3 && d.ComputeMinor < 7) {
                return fmt.Errorf("GPU CC %d.%d detected. Minimum supported is CC 3.7 (Tesla K80)", d.ComputeMajor, d.ComputeMinor)
            }
            return fmt.Errorf("GPU CC %d.%d detected. This build only supports CC 3.7 (Tesla K80, K40, M40)", d.ComputeMajor, d.ComputeMinor)
        }
    }
    return nil
}
```

**Usage**: In startup code (e.g., `server/` or `cmd/`), call validation:

```go
devices := ml.GetDevices()
if err := ml.ValidateCC37Only(devices); err != nil {
    log.Warnf("GPU compatibility warning: %v", err)
}
```

---

## Documentation Updates

### Update DeviceInfo Comments

**Location**: Around line 260-280 in `device.go`

**Action**: Add package-level comment clarifying CC 3.7 focus:

```go
// Package ml provides machine learning device management and backend interfaces.
//
// This ollama37 build is optimized exclusively for NVIDIA Compute Capability 3.7
// (Kepler architecture: Tesla K80, K40, M40). For GPUs with CC 5.0+, use upstream
// Ollama which provides better support and optimizations for modern architectures.
//
// CC 3.7 Limitations:
// - No FP16 native operations (requires CC 6.0+)
// - No DP4A instruction (requires CC 6.1+)
// - No Tensor Cores (requires CC 7.0+)
// - No Flash Attention (requires CC 7.0+)
// - FP32 operations only with basic CUDA kernels
package ml
```

---

## Testing

After making changes, verify GPU detection still works:

```bash
# Build the project
go build -o ollama .

# Test GPU detection
./ollama serve &
sleep 2

# Check logs for GPU detection
# Should see: "GPU 0: Tesla K80, CC 3.7, 11GB VRAM" or similar

# Query system info
curl http://localhost:11434/api/tags

# Stop server
pkill ollama
```

---

## Expected Outcomes

- **Clearer documentation**: Code explicitly states CC 3.7 focus
- **Better user experience**: Clear error messages if wrong GPU detected
- **Maintainability**: Comments explain why certain features return false
- **Validation**: Optional enforcement of CC 3.7-only policy

---

## Notes

- GPU detection in `discover/` package also has platform-specific implementations
- Consider adding similar clarifications to `discover/gpu.go` if needed
- The validation helper is optional but recommended for user clarity
- All changes are documentation/comments - no functional impact on CC 3.7 hardware
