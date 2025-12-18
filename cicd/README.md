# CI/CD Infrastructure

This folder contains CI/CD infrastructure and the test framework for validating ollama37 builds on Tesla K80 GPUs.

## Quick Start

```bash
# Navigate to test framework
cd cicd/tests

# Install dependencies
npm install

# Run all tests
npm run test

# Run specific suite
npm run test -- --suite build
npm run test -- --suite runtime
npm run test -- --suite inference

# Run without LLM judge
npm run test -- --no-llm

# List available tests
npm run list
```

## Components

### Test Framework (`tests/`)

TypeScript-based test framework with dual-judge architecture.

**Features:**
- YAML-based test case definitions
- Docker log collection with precise boundaries
- Dual judge system (simple + LLM)
- JSON and console output formats
- Pattern matching for test validation

**Test Suites:**
| Suite | Tests | Purpose |
|-------|-------|---------|
| Build | 3 | Verify Docker images and toolchain |
| Runtime | 3 | Container startup, GPU detection |
| Inference | 3 | Model loading, API endpoints |

### LLM Judge (`infrastructure/docker-compose.judge.yml`)

A stable reference Ollama instance for semantic test evaluation.

**Architecture:**
```
Port 11434 → ollama37 (test subject, local build)
Port 11435 → ollama37-judge (stable reference, DockerHub)
```

**Usage:**
```bash
# Start judge container
cd cicd/infrastructure
docker compose -f docker-compose.judge.yml up -d

# Pull model for judging (first time)
curl -X POST http://localhost:11435/api/pull -d '{"name": "gemma3:4b"}'

# Stop judge
docker compose -f docker-compose.judge.yml down
```

## Folder Structure

```
cicd/
├── docs/
│   ├── CICD.md              # Design philosophy
│   └── PLAN.md              # Infrastructure planning
├── infrastructure/
│   ├── docker-compose.judge.yml
│   └── README.md
├── specs/
│   ├── build.md             # Build test specifications
│   ├── runtime.md           # Runtime test specifications
│   └── inference.md         # Inference test specifications
├── tests/
│   ├── src/                 # Framework source code
│   ├── testcases/           # YAML test definitions
│   ├── package.json
│   └── tsconfig.json
├── results/                 # Test output (gitignored)
└── README.md                # This file
```

## Related Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Test subject | `docker/docker-compose.yml` | Ollama build being tested |
| Builder image | `docker/builder/Dockerfile` | Build toolchain container |
| Runtime image | `docker/runtime/Dockerfile` | Compiled binary container |
| Test framework | `cicd/tests/` | Test execution and judging |
| Test specs | `cicd/specs/` | Test case specifications |

## Documentation

- [CICD.md](docs/CICD.md) - Design philosophy and architecture
- [PLAN.md](docs/PLAN.md) - Infrastructure planning and checklist
