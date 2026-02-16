---
description: Manage isolated Docker containers for YOLO mode, data projects, or risky operations.
---

# Container Management

Manage isolated Docker containers where Claude has full, unrestricted access. Containers are disposable — project files persist on the host via bind mount.

## Prerequisites

If Docker is not available, run the one-time setup:
```bash
~/.claude/container/setup.sh
```
This installs Colima + Docker + Just and builds the container image.

## Available Operations

All operations use `just` recipes from `~/.claude/container/`:

| Operation | Command | Description |
|-----------|---------|-------------|
| **Create** | `just -f ~/.claude/container/Justfile create <name>` | Create a new container with project directory |
| **YOLO** | `just -f ~/.claude/container/Justfile yolo <name>` | Start Claude with full permissions (no prompts) |
| **Safe** | `just -f ~/.claude/container/Justfile safe <name>` | Start Claude with normal permissions |
| **Shell** | `just -f ~/.claude/container/Justfile shell <name>` | Open a bash shell inside the container |
| **Destroy** | `just -f ~/.claude/container/Justfile destroy <name>` | Remove container (project files persist) |
| **List** | `just -f ~/.claude/container/Justfile list` | Show all containers and their status |
| **Login** | `just -f ~/.claude/container/Justfile login <name>` | Authenticate Claude (subscription users) |

## Usage

Based on `$ARGUMENTS`, run the appropriate command above. Parse the first word as the operation and the second as the container name.

Examples:
- `/container create data-analysis` → runs `just create data-analysis`
- `/container yolo data-analysis` → runs `just yolo data-analysis`
- `/container list` → runs `just list`

## Container Details

- **Project files**: `~/.claude/container/projects/<name>/` ↔ `/workspace` inside container
- **Workflow config**: Your rules, agents, and commands are bind-mounted read-only
- **Stack**: Node 22, Python 3/uv, Deno, DuckDB, git, jq, just
- **Pairs well with**: `/explore` for experimental work inside containers
