# Container Environment

You are running inside an **isolated Docker container**. This is a disposable environment — you can install anything, break anything, and none of it touches the host system.

## Workspace

- `/workspace` is bind-mounted from the host. Files here persist when the container is destroyed.
- Everything outside `/workspace` is ephemeral — container destruction wipes it.

## Available Tools

- **Node.js 22** + npm
- **Python 3** + uv (use `uv pip install` instead of pip)
- **Deno** (for edge functions, scripts)
- **DuckDB CLI** (for data exploration)
- **just** (command runner)
- **git**, **jq**, **curl**, **build-essential**

## Install Freely

```bash
sudo apt-get update && sudo apt-get install -y <package>   # system packages
uv pip install <package>                                     # python packages
npm install -g <package>                                     # node packages
```

## Workflow Rules

Your transversal rules, agents, and commands are available via bind-mounted config at `~/.claude/`. Use them as normal — the same workflow intelligence applies here, just with full permissions.

## Key Principle

Container = sandbox. Experiment boldly. If something breaks, destroy and recreate.
