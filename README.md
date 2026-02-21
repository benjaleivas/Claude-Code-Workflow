# claude-code-workflow

A structured workflow system for [Claude Code](https://code.claude.com/docs) that adds planning, code review, git enforcement, and persistent learning on top of the base tool. Everything lives in `~/.claude/` and loads automatically across all your projects.

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

Every non-trivial task follows this lifecycle:

```
feature branch → plan → implement → verify → /review → /commit
     |                                                      |
  (auto by                         /grill → fix → /pr (push + PR)
  orchestrator)                                             |
                     /techdebt → /update-tracker → /commit → close
```

1. **Plan mode** (Shift+Tab twice) explores the problem, asks clarifying questions, writes a spec, runs devil's advocate, then proposes a blueprint
2. **Orchestrator** auto-activates after plan approval: creates a feature branch, implements the plan, runs verification, triggers review
3. **Review pipeline** catches issues at multiple levels (quick `/review`, thorough `/grill`, automated `/qa` loops)
4. **Post-PR tracking** reminds you to merge and clean up the branch

For quick fixes (single file, under ~20 lines), the planning overhead is skipped — just edit, verify, and commit directly to main.

## Components

### Agents

Custom agents with persistent memory and specialized tool access. These are spawned as subagents to handle focused tasks without polluting the main conversation context.

| Agent | Memory | Tools | Use When |
|-------|--------|-------|----------|
| `code-reviewer` | user | Read, Grep, Glob, Bash | Pre-commit reviews, PR reviews, /qa critic |
| `debugger` | user | Read, Write, Edit, Bash, Grep, Glob | Errors, test failures, unexpected behavior |
| `security-reviewer` | user | Read, Grep, Glob, Bash | Auth changes, input handling, RLS, secrets |
| `test-writer` | project | All | After implementing features, coverage gaps |
| `supabase-specialist` | user | All + /spec | Any Supabase work (auth, DB, edge functions) |
| `expo-specialist` | user | All | React Native/Expo mobile development |

### Commands

Slash commands available via `/command-name`. These automate repetitive workflows so you don't have to re-prompt the same instructions every session.

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

#### Review Tool Chooser

Multiple review tools exist for different situations:

| Situation | Tool | Time |
|-----------|------|------|
| Quick check before commit | `/review` | 30s |
| Thorough review with memory | `code-reviewer` agent | 5 min |
| Automated critic-fixer loop | `/qa` | 5-15 min |
| Adversarial pre-push gate | `/grill` | 5 min |
| Security-specific audit | `security-reviewer` agent | 5 min |

### Hooks

Event-driven shell scripts that run automatically in response to Claude Code lifecycle events. Configured in `settings.json`.

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
| `check-open-pr.sh` | Stop | Remind about open PRs before session ends |
| `notify.sh` | Notification | System notifications for permission/idle prompts |

### Rules

Markdown files that auto-load every session and guide Claude's behavior. These define the planning workflow, execution protocol, and quality standards.

| Rule | Purpose |
|------|---------|
| `structured-thinking.md` | XML thinking tags (`<brainstorm>`, `<analysis>`, `<decision>`) for plan mode |
| `plan-mode-workflow.md` | 5-phase planning: thinking, questions, blueprint with specs, devil's advocate, propose |
| `orchestrator-protocol.md` | Post-plan execution loop: branch, implement, verify, review, fix, report |
| `spec-before-code.md` | Data shapes, API contracts, edge cases, and success criteria before implementation |
| `subagent-patterns.md` | Agent spawning patterns, team coordination, and failure handling |
| `session-logging.md` | Compression-resistant reasoning history written to disk |
| `learn-system.md` | Persistent `[LEARN:tag]` corrections that compound across sessions |
| `branching-strategy.md` | Feature branch conventions, orchestrator integration, cleanup |
| `new-project-setup.md` | Project CLAUDE.md scaffolding for new codebases |

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
| [Claude Code Documentation](https://code.claude.com/docs) | Anthropic | Hooks API, agent YAML format, settings.json schema, slash commands, MCP integration |
| [Boris Cherny's Claude Code Setup](https://x.com/bcherny/status/2007179832300581177) | Boris Cherny | PostToolUse formatting hook, `/permissions` pattern, verify-app subagent, plan-first workflow, shared CLAUDE.md as compounding knowledge |
| [Claude Code Changes How I Work](https://causalinf.substack.com/p/claude-code-changes-how-i-work-part) | Scott Cunningham | Devil's advocate agent pattern for combating LLM overconfidence |
| [claude-container](https://github.com/paulgp/claude-container) | Paul Goldsmith-Pinkham | Docker isolation with Colima + Justfile for safe YOLO mode |
| [Claude Code: My Workflow](https://psantanna.com/claude-code-my-workflow/) | Pedro Sant'Anna | Multi-agent verification, critic-fixer loops, quality gates, persistent learning via MEMORY.md |
| [Intelligent AI Delegation](https://arxiv.org/abs/2602.11865) | Academic paper | Agent failure handling, stall detection, team cost heuristics |
| [Intro to Multiagent Systems](https://www.linkedin.com/feed/update/urn:li:activity:7328490306763481088/) | Celeste Bean | Multiagent design patterns, agent-friendly task classification |
| [OWASP Top 10](https://owasp.org/www-project-top-ten/) | OWASP Foundation | Security reviewer agent's vulnerability checklist |

## License

MIT License. See [LICENSE](LICENSE) for details.
