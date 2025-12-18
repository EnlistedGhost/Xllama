# CI/CD Infrastructure

Docker containers required on the GitHub Actions self-hosted runner.

## LLM Judge (`docker-compose.judge.yml`)

A stable Ollama instance for evaluating test results.

**Why it's needed:**
- The test subject (the Ollama build being tested) runs on port 11434
- The judge must be a separate, known-good instance to evaluate if tests pass
- Uses the stable DockerHub image, not the build under test

**Port mapping:**
```
11434 → Test subject (ollama37 build being tested)
11435 → LLM Judge (stable reference)
```

**Setup on runner:**
```bash
cd cicd/infrastructure
docker compose -f docker-compose.judge.yml up -d

# Pull a judge model (first time only)
curl -X POST http://localhost:11435/api/pull -d '{"name": "gemma3:1b"}'
```

**Verify:**
```bash
docker ps | grep ollama37-judge
curl http://localhost:11435/api/tags
```
