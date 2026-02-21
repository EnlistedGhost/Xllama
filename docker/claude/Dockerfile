# Claude Code CLI container
# Connects to ollama37 container as backend
#
# Build:  docker compose -f docker/docker-compose.claude.yml build
# Run:    docker compose -f docker/docker-compose.claude.yml run --rm claude-code

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (Claude Code blocks --dangerously-skip-permissions as root)
RUN useradd -m -s /bin/bash claude

# Install Claude Code via native installer as the claude user
USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash

# Ollama backend configuration
ENV ANTHROPIC_AUTH_TOKEN=ollama
ENV ANTHROPIC_API_KEY=""
ENV ANTHROPIC_BASE_URL=http://ollama37:11434
ENV ANTHROPIC_MODEL=gpt-oss:20b-32k
ENV DISABLE_AUTOUPDATER=1

WORKDIR /workspace

ENTRYPOINT ["/home/claude/.local/bin/claude"]
CMD ["--model", "gpt-oss:20b-32k"]
