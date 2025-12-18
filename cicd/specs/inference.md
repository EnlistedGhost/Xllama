# Inference Tests

Exported from TestLink project: **ollama37**

---

## TC-INFERENCE-001: Model Pull

**External ID:** ollama37-14
**Importance:** High
**Execution Type:** Automated

**Summary:**
Pull the gemma3:4b model for testing inside the container.

### Steps

| # | Action | Expected Result |
|---|--------|-----------------|
| 1 | Pull test model:<br>`docker exec ollama37 ollama pull gemma3:4b` | Model downloads successfully or reports already exists |
| 2 | Verify model available:<br>`docker exec ollama37 ollama list` | gemma3:4b listed in output |

---

## TC-INFERENCE-002: Basic Inference

**External ID:** ollama37-15
**Importance:** High
**Execution Type:** Automated

**Summary:**
Run basic inference test with gemma3:4b model.

### Steps

| # | Action | Expected Result |
|---|--------|-----------------|
| 1 | Run simple inference:<br>`docker exec ollama37 ollama run gemma3:4b "What is 2+2? Answer with just the number." --verbose 2>&1` | Model responds with '4' or equivalent number |
| 2 | Check GPU memory usage during inference:<br>`docker exec ollama37 nvidia-smi --query-compute-apps=pid,used_memory --format=csv` | Ollama process shows GPU memory allocation |

---

## TC-INFERENCE-003: API Endpoint Test

**External ID:** ollama37-16
**Importance:** Medium
**Execution Type:** Automated

**Summary:**
Test the Ollama REST API /api/generate endpoint.

### Steps

| # | Action | Expected Result |
|---|--------|-----------------|
| 1 | Test generate endpoint:<br>`curl -s http://localhost:11434/api/generate -d '{"model":"gemma3:4b","prompt":"Say hello","stream":false}'` | Returns JSON with 'response' field containing greeting |
| 2 | Test streaming response:<br>`curl -s http://localhost:11434/api/generate -d '{"model":"gemma3:4b","prompt":"Count 1 to 3","stream":true}' \| head -3` | Returns multiple JSON lines with streamed tokens |
