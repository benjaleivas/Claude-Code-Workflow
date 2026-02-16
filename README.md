# claude-workflow

Transversal Claude Code configuration: agents, commands, hooks, and rules that load automatically across all projects. Built for a solo developer working on React Native/Expo, Supabase/Deno, and data projects.

## Quick Start

```bash
git clone https://github.com/bleiva/claude-workflow.git
cd claude-workflow
./install.sh
```

The install script symlinks everything into `~/.claude/`. Edits to files in this repo are live immediately.

To undo: `./uninstall.sh` copies files back and removes symlinks.

## Inventory

| Category | Count | Location |
|----------|-------|----------|
| Agents | 6 | `agents/` |
| Commands | 17 | `commands/` |
| Hooks | 9 | `hooks/` |
| Rules | 8 | `rules/` |
| Container | 5 | `container/` |

## Agents

Custom agents with persistent memory and specialized tool access.

| Agent | Memory | Tools | Use When |
|-------|--------|-------|----------|
| `code-reviewer` | user | Read, Grep, Glob, Bash | Pre-commit reviews, PR reviews, /qa critic |
| `debugger` | user | Read, Write, Edit, Bash, Grep, Glob | Errors, test failures, unexpected behavior |
| `security-reviewer` | user | Read, Grep, Glob, Bash | Auth changes, input handling, RLS, secrets |
| `test-writer` | project | All | After implementing features, coverage gaps |
| `supabase-specialist` | user | All + /spec | Any Supabase work (auth, DB, edge functions) |
| `expo-specialist` | user | All | React Native/Expo mobile development |

## Commands

Slash commands available via `/command-name`.

| Command | Description |
|---------|-------------|
| `/review` | Quick review of uncommitted changes. Returns SHIP/ALMOST/REWORK verdict |
| `/grill` | Adversarial code review. Skeptical staff engineer perspective |
| `/qa` | Automated critic-fixer loop. Max 3 rounds. Use `/qa security` for security focus |
| `/commit` | Commit current changes with a clear message |
| `/pr` | Push branch and create a pull request |
| `/explore` | Enter exploration mode with relaxed quality gates |
| `/container` | Manage isolated Docker containers for YOLO mode |
| `/devils-advocate` | Challenge the current approach with systematic skepticism |
| `/spec` | Generate an upfront specification before coding |
| `/simplify` | Simplify code that was just written |
| `/techdebt` | End-of-session codebase cleanup |
| `/test-and-fix` | Run tests and fix any failures |
| `/ralph-loop` | Autonomous test iteration loop (runs tests, fixes, repeats) |
| `/cancel-ralph` | Cancel an active Ralph loop |
| `/fix-ci` | Diagnose and fix failing CI |
| `/update-tracker` | Update the work tracker with session progress |
| `/verify-ui` | Visually verify UI changes in Chrome |

### Review Tool Chooser

| Situation | Tool | Time |
|-----------|------|------|
| Quick check before commit | `/review` | 30s |
| Thorough review with memory | `code-reviewer` agent | 5 min |
| Automated critic-fixer loop | `/qa` | 5-15 min |
| Adversarial pre-push gate | `/grill` | 5 min |
| Security-specific audit | `security-reviewer` agent | 5 min |

## Hooks

Event-driven automations configured in `settings.json`.

| Hook | Event | Purpose |
|------|-------|---------|
| `session-init.sh` | SessionStart | Load environment, check prerequisites |
| `prompt-validator.sh` | UserPromptSubmit | Validate prompts before processing |
| `protect-files.sh` | PreToolUse (Edit/Write) | Prevent modifications to protected files |
| `auto-format.sh` | PostToolUse (Edit/Write) | Auto-format after file changes |
| `scan-secrets.sh` | PostToolUse (Edit/Write) | Scan for accidentally committed secrets |
| `suggest-verify.sh` | PostToolUse (Edit/Write) | Remind to run verification after changes |
| `pre-compact.sh` | PreCompact | Save context before auto-compression |
| `session-cleanup.sh` | SessionEnd | Clean up temporary resources |
| `notify.sh` | Notification | System notifications for permission/idle prompts |

Additionally, a **prompt-type Stop hook** checks whether a session log reminder is needed after plan-mode work.

## Rules

Auto-loaded rules that guide every session.

| Rule | Purpose |
|------|---------|
| `structured-thinking.md` | XML thinking tags for plan mode |
| `plan-mode-workflow.md` | 5-phase planning workflow |
| `orchestrator-protocol.md` | Post-plan execution loop |
| `spec-before-code.md` | Specification requirements before implementation |
| `subagent-patterns.md` | Agent spawning patterns and team coordination |
| `session-logging.md` | Compression-resistant reasoning history |
| `learn-system.md` | Persistent [LEARN] tag corrections |
| `new-project-setup.md` | Project CLAUDE.md scaffolding |

## Daily Workflow

```
Write code → verify → /review → /commit
                                    ↓
               /grill → fix → /pr (when ready to push)
                                    ↓
         /techdebt → /update-tracker → /commit → close
```

## Container (Docker Isolation)

Run Claude in an isolated Docker container with full permissions (YOLO mode). Requires Colima + Docker.

```bash
# One-time setup
cd container && ./setup.sh

# Or use the Justfile
just setup              # install deps + build image
just create my-project  # create a container
just yolo my-project    # start Claude with full permissions
just shell my-project   # get a bash shell
just destroy my-project # remove container (files persist)
just list               # show all containers
```

Project files persist at `container/projects/<name>/` — container destruction doesn't affect them.

## Structure

```
~/.claude/
├── CLAUDE.md           → repo/CLAUDE.md (symlink)
├── settings.json       → repo/settings.json (symlink)
├── agents/             → repo/agents/ (symlink)
├── commands/           → repo/commands/ (symlink)
├── hooks/              → repo/hooks/ (symlink)
├── rules/              → repo/rules/ (symlink)
├── container/          → repo/container/ (symlink)
├── cache/              (local, not tracked)
├── debug/              (local, not tracked)
├── plans/              (local, not tracked)
├── plugins/            (local, not tracked)
├── session-env/        (local, not tracked)
├── todos/              (local, not tracked)
└── ...
```

## Adding New Components

### New agent
1. Create `agents/<name>.md` with YAML frontmatter (name, description, tools, model, memory, maxTurns)
2. Add to `subagent-patterns.md` table and CLAUDE.md Custom Agents line

### New command
1. Create `commands/<name>.md` with YAML frontmatter (description, optionally context/allowed-tools)
2. Add to appropriate section in CLAUDE.md slash commands

### New hook
1. Create `hooks/<name>.sh` (make executable)
2. Register in `settings.json` under the appropriate event

### New rule
1. Create `rules/<name>.md`
2. Add to CLAUDE.md Detailed Rules section
