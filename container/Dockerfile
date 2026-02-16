FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl git jq ca-certificates unzip sudo \
    python3 python3-pip python3-venv python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs && npm i -g npm@latest

# Non-root user with sudo
RUN useradd -m -s /bin/bash -u 1000 coder \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER coder
WORKDIR /home/coder

# uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/coder/.local/bin:$PATH"

# Deno
RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_DIR="/home/coder/.deno"
ENV PATH="/home/coder/.deno/bin:$PATH"

# DuckDB CLI (architecture-aware)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then DDB_ARCH="linux-aarch64"; else DDB_ARCH="linux-amd64"; fi && \
    curl -L "https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-${DDB_ARCH}.zip" -o /tmp/duckdb.zip && \
    sudo unzip /tmp/duckdb.zip -d /usr/local/bin && sudo chmod +x /usr/local/bin/duckdb && rm /tmp/duckdb.zip

# just (command runner)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin

# Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Locale
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

WORKDIR /workspace
CMD ["sleep", "infinity"]
