# Claude Code Workflow

A structured workflow system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that adds planning discipline, automated quality gates, and persistent learning. Everything lives in `~/.claude/` and loads automatically across all your projects.

## Why This Exists

Claude Code is powerful out of the box, but it doesn't impose structure. It won't plan before coding, review its own work, enforce branching conventions, or remember mistakes across sessions.

This workflow fills those gaps with three principles:

1. **Plan first, then execute.** Every non-trivial task goes through structured thinking, clarifying questions, a spec, and a devil's advocate review — before a single line of code is written.
2. **Automate the quality loop.** Hooks auto-format code, scan for secrets, and protect sensitive files on every edit. The orchestrator sequences verification, review, and cleanup automatically after plan approval.
3. **Compound corrections over time.** `[LEARN]` tags persist mistakes to disk so they're never repeated. Session logs survive context compression. Worktrees are archived for future reference.

## Get Started

```bash
git clone https://github.com/benjaleivas/claude-code-workflow.git
cd claude-code-workflow
./install.sh
```

This creates symlinks from `~/.claude/` to files in the repo. Changes you make here are live immediately — no reinstall needed. Existing files are backed up to `~/.claude/.backup-<timestamp>/`.

To verify: start Claude Code in any project and run `/review` or `/commit`.

To undo: `./uninstall.sh` replaces symlinks with standalone file copies.

## Architecture

```
~/.claude/
├── CLAUDE.md          Main instructions — loaded every session
├── settings.json      Hooks, permissions, status line, plugins
├── rules/             Behavioral rules (auto-loaded)
├── agents/            Specialized subprocesses with persistent memory
├── commands/          Slash commands (legacy format)
├── skills/            Slash commands (modern format, progressive disclosure)
├── hooks/             Event-driven shell scripts
└── container/         Docker isolation setup
```

Everything is modular. You can adopt individual pieces (just the hooks, just the agents) or the full system.

### How a Session Flows

```
New session → classify task
│
├─ Quick fix (<20 lines, 1 file)
│  └─ fix → verify → /commit
│
└─ Non-trivial
   └─ worktree → plan → [approve] → orchestrator auto-activates:
      implement → verify → simplify → review → fix → commit → PR → cleanup
```

The orchestrator is the key automation. Once you approve a plan, it drives the entire execute-verify-review-ship loop using existing slash commands — you don't run each step manually.

## What's Included

### Rules (the behavioral backbone)

Rules are markdown files that define how Claude thinks, plans, and works. They auto-load every session.

| What | Why |
|------|-----|
| **Structured thinking** | Forces `<brainstorm>` → `<analysis>` → `<decision>` tags so Claude explores alternatives before committing to an approach |
| **Plan mode workflow** | 5-phase planning (think → ask → spec → challenge → propose) catches design errors before implementation |
| **Orchestrator protocol** | Automates the post-plan loop so verification, simplification, review, and cleanup happen consistently |
| **Spec before code** | Requires data shapes, contracts, and edge cases upfront — reduces iteration cycles |
| **Session logging** | Writes reasoning to disk so it survives context compression — the conversation is ephemeral, the log is permanent |
| **[LEARN] system** | Tagged corrections (`[LEARN:supabase] RLS doesn't apply to service role`) that compound across sessions |
| **Branching strategy** | `feature/`, `fix/`, `chore/` convention with automatic branch creation and cleanup |

### Agents (specialized subprocesses)

Agents run in isolated context windows with their own memory. They handle focused tasks without polluting the main conversation.

| Agent | Why It Exists |
|-------|---------------|
| **code-reviewer** | Dependency-graph-aware review — holds core code to higher standards than leaf code |
| **debugger** | 5-phase root cause analysis (capture → hypothesize → isolate → root cause → fix) |
| **security-reviewer** | OWASP Top 10 checklist plus platform-specific checks (RLS, XSS, injection) |
| **test-writer** | Generates tests covering happy path, edge cases, and error paths |
| **supabase-specialist** | Auth, RLS policies, edge functions, migrations |
| **expo-specialist** | React Native/Expo navigation, native modules, EAS builds |

### Commands & Skills

| Phase | Key Commands | What They Do |
|-------|-------------|--------------|
| **Planning** | `/spec`, `/devils-advocate`, `/explore` | Spec out contracts, stress-test plans, prototype freely |
| **Implementing** | `/test-and-fix`, `/ralph-loop`, `/simplify` | Run tests, autonomous fix loops, clean up code |
| **Reviewing** | `/review`, `/grill`, `/qa` | Quick check (30s), adversarial review (5min), automated critic-fixer loop (15min) |
| **Shipping** | `/commit`, `/pr`, `/fix-ci` | WHY-focused commits, PR creation, CI diagnosis |
| **Maintenance** | `/techdebt`, `/update-tracker`, `/container` | Dead code cleanup, work logging, Docker isolation |

### Hooks (event-driven automation)

Hooks fire automatically on Claude Code lifecycle events — you never run them manually.

| What | Why |
|------|-----|
| **auto-format** | Runs Prettier/Black/SwiftFormat on every file edit so code style is never a review issue |
| **scan-secrets** | Async scan for API keys and tokens after every edit — catches accidents before commit |
| **protect-files** | Blocks edits to `.env`, credentials, and lock files |
| **suggest-verify** | Nudges you to run verification after changes accumulate |
| **pre-compact** | Saves reasoning to disk before context compression — prevents knowledge loss |
| **session-init/cleanup** | Detects project type at start, cleans up resources at end |

### Permissions

Pre-approved patterns for routine read-only commands so Claude doesn't prompt for permission on every `git status` or `npm run test`. Destructive operations (`git push`, `npm install`, `rm`) still require confirmation.

### Status Line

Shows model, branch, session cost, and context window usage at a glance:

```
~/project [Opus] (feature/auth) $0.42 ctx:23%
```

### Container (Docker isolation)

For risky operations or data experiments. Runs Claude with full permissions inside an isolated Docker container. Project files persist outside the container.

```bash
cd container && just setup && just yolo my-project
```

## Customization

### Add an agent
Create `agents/<name>.md` with YAML frontmatter (`name`, `description`, `tools`, `model`, `memory`, `maxTurns`).

### Add a command
Create `commands/<name>.md` (simple) or `skills/<name>/SKILL.md` (complex, with reference files and scripts).

### Add a hook
Create `hooks/<name>.sh` (executable), register in `settings.json` under the appropriate event.

### Add a rule
Create `rules/<name>.md`. Add a `paths` frontmatter field to scope it to specific directories.

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
| [Complete Guide to Building Skills for Claude](https://www.anthropic.com/engineering/claude-code-skills-guide) | Anthropic | Skill format best practices — YAML frontmatter, progressive disclosure, negative triggers, agent descriptions |
| [frontend-slides](https://github.com/zarazhangrui/frontend-slides) | zarazhangrui | `/frontend-slides` command — zero-dependency HTML presentation generator with 12 visual presets |
| [ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | nextlevelbuilder | `/ui-ux-pro-max` skill — BM25-powered UI/UX design intelligence with 25 CSV databases covering styles, colors, typography, charts, and 13 framework-specific guidelines |
| [How I use Claude Code (Meta Staff Engineer Tips)](https://www.youtube.com/watch?v=mZzhfPle9QU) | John Kim (Staff Engineer, Meta) | 50 practical tips from daily use — CLAUDE.md structure, plan mode workflow, parallel instances with git worktrees, hooks automation, subagent patterns, plugin ecosystem |

## License

MIT License. See [LICENSE](LICENSE) for details.
