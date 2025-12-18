# Build Tests

Exported from TestLink project: **ollama37**

---

## TC-BUILD-001: Builder Image Verification

**External ID:** ollama37-8
**Importance:** High
**Execution Type:** Automated

**Summary:**
Verify the ollama37-builder Docker image exists and contains required build tools.

### Steps

| # | Action | Expected Result |
|---|--------|-----------------|
| 1 | Check builder image exists:<br>`docker images ollama37-builder:latest --format '{{.Repository}}:{{.Tag}}'` | Output: ollama37-builder:latest |
| 2 | Verify CUDA toolkit installed:<br>`docker run --rm ollama37-builder:latest nvcc --version` | Output contains: Cuda compilation tools, release 11.4 |
| 3 | Verify GCC version:<br>`docker run --rm ollama37-builder:latest gcc --version` | Output contains: gcc (GCC) 10 |
| 4 | Verify Go version:<br>`docker run --rm ollama37-builder:latest go version` | Output contains: go1.25 |

---

## TC-BUILD-002: Runtime Image Build

**External ID:** ollama37-9
**Importance:** High
**Execution Type:** Automated

**Summary:**
Build the ollama37 runtime Docker image from GitHub source.

### Steps

| # | Action | Expected Result |
|---|--------|-----------------|
| 1 | Navigate to docker directory:<br>`cd /home/jack/src/ollama37/docker` | Directory exists |
| 2 | Build runtime image:<br>`make build-runtime 2>&1 \| tee /tmp/build.log` | Build completes with message: Runtime image built successfully! |
| 3 | Verify runtime image exists:<br>`docker images ollama37:latest --format '{{.Repository}}:{{.Tag}} {{.Size}}'` | Output: ollama37:latest with size ~18GB |

---

## TC-BUILD-003: Image Size Validation

**External ID:** ollama37-10
**Importance:** Medium
**Execution Type:** Automated

**Summary:**
Verify Docker image sizes are within expected range.

### Steps

| # | Action | Expected Result |
|---|--------|-----------------|
| 1 | Check builder image size:<br>`docker images ollama37-builder:latest --format '{{.Size}}'` | Size between 10GB and 20GB |
| 2 | Check runtime image size:<br>`docker images ollama37:latest --format '{{.Size}}'` | Size between 15GB and 25GB |
