# CI/CD Infrastructure

This folder contains CI/CD infrastructure components separate from the main build system.

## Components

### LLM Judge (`docker-compose.judge.yml`)

A stable reference Ollama instance for evaluating test results.

**Purpose:**
- Acts as secondary judge alongside simple exit-code checking
- Analyzes test logs semantically to detect hidden issues
- Uses stable DockerHub image (not the build being tested)

**Architecture:**
```
Port 11434 → ollama37 (test subject, local build)
Port 11435 → ollama37-judge (stable reference, DockerHub)
```

**Usage:**
```bash
# Start judge container
cd cicd
docker compose -f docker-compose.judge.yml up -d

# Check status
docker compose -f docker-compose.judge.yml ps

# Pull model for judging (first time)
curl -X POST http://localhost:11435/api/pull -d '{"name": "gemma3:1b"}'

# Stop judge
docker compose -f docker-compose.judge.yml down
```

## Folder Structure

```
cicd/
├── docker-compose.judge.yml   # LLM Judge container
├── README.md                  # This file
└── scripts/                   # (future) CI helper scripts
```

## Related Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Test subject | `docker/docker-compose.yml` | Ollama build being tested |
| Test runner | `tests/src/` | Executes tests, uses judge |
| Test cases | `tests/testcases/` | YAML test definitions |
| Workflows | `.github/workflows/` | CI pipeline definitions |
