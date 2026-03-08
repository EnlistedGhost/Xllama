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

# Pull base model (first time only)
curl -X POST http://localhost:11435/api/pull -d '{"name": "gemma3:12b"}'

# Create judge model with 8K context (first time only)
docker cp Modelfile.judge ollama37-judge:/tmp/Modelfile.judge
docker exec ollama37-judge ollama create gemma3:12b-judge -f /tmp/Modelfile.judge
```

**Verify:**
```bash
docker ps | grep ollama37-judge
docker exec ollama37-judge ollama list  # should show gemma3:12b-judge
```

## Judge Model (`Modelfile.judge`)

Custom model based on `gemma3:12b` with:
- `num_ctx 8192` — doubled from default 4096 to handle test prompts without truncation
- `temperature 0.1` — low temperature for consistent, deterministic judgments
