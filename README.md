# Claude Code Workflow

A structured workflow system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that adds planning, code review, git enforcement, and persistent learning on top of the base tool. Everything lives in `~/.claude/` and loads automatically across all your projects.

## What Is This?

Claude Code is powerful out of the box, but it doesn't impose structure. It won't plan before coding, review its own work, enforce branching conventions, or remember mistakes across sessions. This repo fills those gaps.

**What you get:**

- **5-phase planning workflow** with devil's advocate review before implementation
- **6 specialized agents** (code reviewer, debugger, security reviewer, test writer, and more) with persistent memory
- **17 slash commands** for code review, commits, PRs, testing, and cleanup
- **10 event-driven hooks** that auto-format code, scan for secrets, protect files, and manage sessions
- **Git workflow enforcement** with automatic feature branching, PR tracking, and branch cleanup
- **Docker isolation** for running Claude with full permissions in a sandboxed container
- **Persistent learning** via `[LEARN]` tags that accumulate corrections across sessions

Works in both CLI and Desktop. Desktop users get additional integration: preview auto-verification via `.claude/launch.json`, inline diff review, and PR monitoring with auto-fix/auto-merge.

Built for solo developers and small teams. Works with any tech stack, though it includes specialized agents for React Native/Expo and Supabase/Deno.

## Quick Start

```bash
git clone https://github.com/benjaleivas/claude-code-workflow.git
cd claude-code-workflow
./install.sh
```

The install script creates symlinks from `~/.claude/` to files in this repo. Edits here are live immediately — no reinstall needed.

To verify it's working, start Claude Code in any project and run `/review` or `/commit`. You should see the custom command behavior instead of the defaults.

To undo: `./uninstall.sh` replaces symlinks with file copies, making `~/.claude/` standalone again.

## How It Works

Every session starts by classifying the task. The classification determines how much structure you need:

```
New session
│
├─ Quick fix (single file, <20 lines)
│  └─ fix → verify → /commit → done
│
├─ Non-trivial (feature, bug, multi-file)
│  └─ full lifecycle (see below)
│
├─ Exploration / prototype
│  └─ /explore mode (relaxed quality gates)
│
└─ Risky / data-heavy
   └─ /container (Docker isolation)
```

Quick fixes skip all ceremony — just edit, verify, and commit directly to main.

### Full Lifecycle

For non-trivial work, the system follows five phases. The orchestrator auto-activates after you approve a plan and drives phases 2–4:

```
┌─────────────────────────────────────────────────────────────┐
│  SETUP                                                      │
│  Create worktree → feature branch → load MEMORY.md          │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│  PLAN                                                       │
│  Structured thinking → clarifying questions →               │
│  blueprint + spec → devil's advocate → propose              │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│  EXECUTE  (orchestrator auto-activates)                     │
│  Implement → verify → /review → fix → re-verify            │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│  REVIEW & SHIP                                              │
│  Satisfaction check → /grill → /commit → /pr → CI          │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│  CLEANUP                                                    │
│  Merge PR → delete branch → delete worktree → /techdebt    │
└─────────────────────────────────────────────────────────────┘
```

**Setup** isolates the work in a git worktree with its own feature branch, then loads any relevant [LEARN] corrections from previous sessions.

**Plan** uses structured thinking tags (`<brainstorm>`, `<analysis>`, `<decision>`) to explore the problem, asks clarifying questions, writes a spec with data shapes and edge cases, then runs a devil's advocate review to challenge the approach before committing to it.

**Execute** implements the plan step-by-step, running the project's verification command after each change and triggering a code review before moving on.

**Review & Ship** asks if you're satisfied, offers relevant next actions (review, testing, commit, PR), and pushes to CI.

**Cleanup** merges the PR, deletes the branch and worktree, and runs a tech debt sweep.

## Agents

Agents are specialized subprocesses with their own context window, persistent memory, and tool access. They handle focused tasks without polluting the main conversation.

#### Core

| Agent | Memory | Tools | Use When |
|-------|--------|-------|----------|
| `code-reviewer` | user | Read, Grep, Glob, Bash | Pre-commit reviews, PR reviews, `/qa` critic |
| `debugger` | user | Read, Write, Edit, Bash, Grep, Glob | Errors, test failures, unexpected behavior |
| `security-reviewer` | user | Read, Grep, Glob, Bash | Auth changes, input handling, RLS, secrets |
| `test-writer` | project | All | After implementing features, coverage gaps |

#### Specialist

| Agent | Memory | Tools | Use When |
|-------|--------|-------|----------|
| `supabase-specialist` | user | All + /spec | Any Supabase work (auth, DB, edge functions) |
| `expo-specialist` | user | All | React Native/Expo mobile development |

## Commands

Slash commands available via `/command-name`. Grouped by when you'd use them in the workflow.

### Planning

| Command | Description |
|---------|-------------|
| `/spec` | Generate an upfront specification — data shapes, contracts, edge cases, success criteria |
| `/devils-advocate` | Challenge the current approach with systematic, good-faith skepticism |
| `/explore` | Enter exploration mode with relaxed quality gates for prototyping |

### Implementing

| Command | Description |
|---------|-------------|
| `/test-and-fix` | Run the test suite and fix any failures one at a time |
| `/ralph-loop` | Autonomous test iteration loop — runs tests, analyzes failures, fixes, repeats (max 10 iterations) |
| `/cancel-ralph` | Cancel an active Ralph loop |
| `/verify-ui` | Visually verify UI changes in the browser |
| `/simplify` | Clean and simplify code (runs automatically after every implementation) |

### Reviewing

| Command | Description |
|---------|-------------|
| `/review` | Quick review of uncommitted changes. Returns SHIP / ALMOST / REWORK verdict |
| `/grill` | Adversarial code review from a skeptical staff engineer perspective |
| `/qa` | Automated critic-fixer loop (max 3 rounds). Use `/qa security` for security focus |

Multiple review tools exist because different situations need different levels of scrutiny:

| Situation | Tool | Time |
|-----------|------|------|
| Quick check before commit | `/review` | ~30s |
| Thorough review with memory | `code-reviewer` agent | ~5 min |
| Automated critic-fixer loop | `/qa` | 5–15 min |
| Adversarial pre-push gate | `/grill` | ~5 min |
| Security-specific audit | `security-reviewer` agent | ~5 min |

### Shipping

| Command | Description |
|---------|-------------|
| `/commit` | Stage and commit with a WHY-focused message. Warns on non-trivial changes to main |
| `/pr` | Push branch and create a pull request (GitHub) or merge request (GitLab) |
| `/fix-ci` | Diagnose and fix failing CI checks |

### Maintenance

| Command | Description |
|---------|-------------|
| `/techdebt` | End-of-session cleanup — dead code, unused imports, stale branches |
| `/update-tracker` | Log session work to the project tracker |
| `/container` | Manage isolated Docker containers for YOLO mode |

## Hooks

Event-driven shell scripts that run automatically during Claude Code lifecycle events. Configured in `settings.json`.

### Code Quality

These fire on every file edit to maintain standards automatically:

| Hook | Event | What It Does |
|------|-------|--------------|
| `protect-files.sh` | PreToolUse (Edit/Write) | Blocks edits to `.env`, credentials, lock files |
| `auto-format.sh` | PostToolUse (Edit/Write) | Runs Prettier, Black, or SwiftFormat based on file type |
| `scan-secrets.sh` | PostToolUse (Edit/Write) | Async scan for accidentally introduced API keys and tokens |
| `suggest-verify.sh` | PostToolUse (Edit/Write) | Reminds to run the verification command after changes |

### Session Lifecycle

These manage the session from start to finish:

| Hook | Event | What It Does |
|------|-------|--------------|
| `session-init.sh` | SessionStart | Detects project type, announces MEMORY.md and available agents |
| `pre-compact.sh` | PreCompact | Saves context snapshot to session log before auto-compression |
| `session-cleanup.sh` | SessionEnd | Cleans up temporary resources |
| `check-open-pr.sh` | Stop | Reminds about open PRs on the current branch before exit |
| `notify.sh` | Notification | System notifications for permission and idle prompts |

### Input Processing

| Hook | Event | What It Does |
|------|-------|--------------|
| `prompt-validator.sh` | UserPromptSubmit | Validates prompts before processing |

## Rules

Rules are markdown files that auto-load every session and define how Claude plans, executes, and maintains quality. They're the behavioral backbone of the workflow.

| Rule | Purpose |
|------|---------|
| `structured-thinking` | XML thinking tags for mandatory plan-mode reasoning |
| `plan-mode-workflow` | 5-phase planning: thinking → questions → blueprint → devil's advocate → propose |
| `orchestrator-protocol` | Post-plan execution loop: branch → implement → verify → review → fix |
| `spec-before-code` | Data shapes, API contracts, edge cases before implementation |
| `session-lifecycle` | Full session lifecycle from setup checklist to cleanup |
| `subagent-patterns` | Agent spawning patterns, team coordination, failure handling |
| `session-logging` | Compression-resistant reasoning history written to disk |
| `learn-system` | Persistent `[LEARN:tag]` corrections that compound across sessions |
| `branching-strategy` | Feature branch conventions, orchestrator integration, cleanup |
| `new-project-setup` | Project CLAUDE.md scaffolding for new codebases |

## Container (Docker Isolation)

Run Claude in an isolated Docker container with full permissions (YOLO mode). Useful for risky operations, data experiments, or when you want to install packages freely without affecting your host system. Requires Colima + Docker.

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

## Installation Details

### How `install.sh` works

The install script creates symlinks from `~/.claude/` pointing to files in this repo:

```
~/.claude/
├── CLAUDE.md           → repo/CLAUDE.md (symlink)
├── settings.json       → repo/settings.json (symlink)
├── agents/             → repo/agents/ (symlink)
├── commands/           → repo/commands/ (symlink)
├── hooks/              → repo/hooks/ (symlink)
├── rules/              → repo/rules/ (symlink)
├── container/          → repo/container/ (symlink)
├── plans/              (local, not tracked)
├── session-logs/       (local, not tracked)
├── plugins/            (local, not tracked)
└── ...
```

Existing non-symlink files are backed up to `~/.claude/.backup-<timestamp>/` before being replaced.

### How `uninstall.sh` works

Replaces all symlinks with copies of the actual files, making `~/.claude/` fully standalone with no dependency on this repo.

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

## References

Sources that informed the design of this workflow system:

| Source | Author | What It Informed |
|--------|--------|-----------------|
| [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code) | Anthropic | Hooks API, agent YAML format, settings.json schema, slash commands, MCP integration |
| [Boris Cherny's Claude Code Setup](https://x.com/bcherny/status/2007179832300581177) | Boris Cherny (Claude Code creator) | PostToolUse formatting hook, `/permissions` pattern, verify-app subagent, plan-first workflow, shared CLAUDE.md as compounding knowledge |
| [Claude Code Changes How I Work](https://causalinf.substack.com/p/claude-code-changes-how-i-work-part) | Scott Cunningham (Researcher) | Devil's advocate agent pattern for combating LLM overconfidence |
| [claude-container](https://github.com/paulgp/claude-container) | Paul Goldsmith-Pinkham (Researcher) | Docker isolation with Colima + Justfile for safe YOLO mode |
| [Claude Code: My Workflow](https://psantanna.com/claude-code-my-workflow/) | Pedro Sant'Anna (Researcher) | Multi-agent verification, critic-fixer loops, quality gates, persistent learning via MEMORY.md |
| [Intelligent AI Delegation](https://arxiv.org/abs/2602.11865) | Academic paper | Agent failure handling, stall detection, team cost heuristics |
| [Intro to Multiagent Systems](https://www.linkedin.com/feed/update/urn:li:activity:7328490306763481088/) | Celeste Bean (Stanford GSB) | Multiagent design patterns, agent-friendly task classification |
| [OWASP Top 10](https://owasp.org/www-project-top-ten/) | OWASP Foundation | Security reviewer agent's vulnerability checklist |

## License

MIT License. See [LICENSE](LICENSE) for details.
