# Claude Code Workflow

A structured workflow system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that adds planning discipline, automated quality gates, and persistent learning. Lives in `~/.claude/` and loads automatically across all projects.

## Why

Claude Code doesn't impose structure on its own. This workflow adds:

1. **Plan first, then execute.** Non-trivial tasks go through structured thinking, specs, and a devil's advocate review before any code is written.
2. **Separate generator from evaluator.** A mandatory acceptance gate spawns a separate agent to verify implementation against spec criteria — because agents reliably praise their own work.
3. **Automate the quality loop.** Hooks format code, scan for secrets, and protect sensitive files on every edit. The orchestrator sequences verification, acceptance gate, review, and cleanup after plan approval.
4. **Resist rationalization.** Iron laws, red flag thought patterns, and rationalization tables prevent process-skipping. Evidence-based verification — no hedging language, show exact pass/fail counts.
5. **Compound corrections over time.** `[LEARN]` tags persist mistakes so they're never repeated. Session logs survive context compression. Worktrees archive decisions for future reference.

## Get Started

```bash
git clone https://github.com/benjaleivas/claude-code-workflow.git
cd claude-code-workflow
./install.sh
```

Creates symlinks from `~/.claude/` to the repo. Changes are live immediately. Existing files are backed up. To undo: `./uninstall.sh`.

## How a Session Flows

```
New session → classify task
│
├─ Quick fix (<20 lines, 1 file)
│  └─ fix → verify → /simplify → /commit
│
└─ Non-trivial
   └─ worktree → plan (with scope gear) → approve → orchestrator:
      implement → verify → simplify → acceptance gate → review → fix → commit → PR → cleanup
```

Once you approve a plan, the orchestrator drives the entire loop — you don't run each step manually.

## What's Inside

```
~/.claude/
├── CLAUDE.md          Main instructions (loaded every session)
├── settings.json      Hooks, permissions, status line
├── rules/             Behavioral rules (auto-loaded)
├── agents/            Specialized subprocesses with persistent memory
├── commands/          Slash commands
├── skills/            Advanced skills (browse daemon, UI design, presentations)
├── hooks/             Event-driven shell scripts
└── container/         Docker isolation for risky operations
```

### Rules

Define how Claude thinks, plans, and works. Key rules:

- **Structured thinking** — `<brainstorm>` → `<analysis>` → `<decision>` tags before committing to an approach
- **Plan mode** — 5-phase workflow: think → ask → spec → devil's advocate → propose
- **Scope gears** — EXPANSION / HOLD SCOPE / REDUCTION to set planning posture
- **Orchestrator** — automates the post-plan loop with mandatory acceptance gate
- **Anti-rationalization** — iron laws, red flag patterns, rationalization tables to prevent process-skipping
- **Acceptance gate** — separate evaluator agent checks implementation against spec criteria (max 2 rounds, then escalates to user)
- **Locked interfaces** — exact type definitions and function signatures frozen at plan time to prevent implementation drift
- **Spec before code** — data shapes, contracts, edge cases, error & rescue maps, binary pass/fail acceptance criteria
- **Session logging** — reasoning persisted to disk (survives context compression)
- **[LEARN] system** — tagged corrections that compound across sessions
- **Branching strategy** — `feature/`, `fix/`, `chore/` with automatic creation and cleanup

### Agents

Run in isolated context with their own memory:

- **code-reviewer** — dependency-graph-aware review
- **debugger** — 5-phase root cause analysis
- **security-reviewer** — OWASP Top 10 + platform-specific checks
- **test-writer** — happy path, edge cases, error paths
- **supabase-specialist** — auth, RLS, edge functions, migrations
- **expo-specialist** — React Native/Expo, navigation, EAS builds

### Commands & Skills

| Phase | Commands |
|-------|----------|
| **Plan** | `/spec`, `/devils-advocate`, `/explore`, `/architect` |
| **Implement** | `/test-and-fix`, `/ralph-loop`, `/simplify` |
| **Review** | `/review` (30s), `/grill` (adversarial), `/qa` (critic-fixer loop) |
| **Ship** | `/commit`, `/pr`, `/fix-ci` |
| **Maintain** | `/techdebt`, `/retro`, `/update-tracker`, `/container` |
| **Verify** | `/verify-ui` (browse daemon / preview / Chrome) |

### Hooks

Fire automatically on Claude Code lifecycle events:

- **auto-format** — Prettier/Black/SwiftFormat on every edit
- **scan-secrets** — async scan for API keys after every edit
- **protect-files** — blocks edits to `.env`, credentials, lock files
- **suggest-verify** — nudges verification after changes accumulate
- **pre-compact** — saves reasoning before context compression
- **session-init/cleanup** — project detection at start, resource cleanup at end

### Browse Daemon

Integrated from [gstack](https://github.com/garrytan/gstack) — a persistent headless Chromium daemon with ~100-200ms latency and near-zero context cost (vs ~30-40K tokens for Chrome MCP). Used by `/verify-ui` for fast visual verification, screenshots, console error checks, and authenticated testing via cookie import.

## References

Sources that informed this workflow:

| Source | Author | Contribution |
|--------|--------|-------------|
| [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code) | Anthropic | Hooks API, agent format, settings schema, slash commands, MCP |
| [Building Skills for Claude](https://www.anthropic.com/engineering/claude-code-skills-guide) | Anthropic | Skill format, progressive disclosure, agent descriptions |
| [gstack](https://github.com/garrytan/gstack) | Garry Tan | Browse daemon, scope gears, two-pass review structure, error & rescue maps, `/retro` retrospectives |
| [Boris Cherny's Claude Code Setup](https://x.com/bcherny/status/2007179832300581177) | Boris Cherny | Formatting hooks, plan-first workflow, CLAUDE.md as compounding knowledge |
| [Claude Code Changes How I Work](https://causalinf.substack.com/p/claude-code-changes-how-i-work-part) | Scott Cunningham | Devil's advocate pattern for combating LLM overconfidence |
| [claude-container](https://github.com/paulgp/claude-container) | Paul Goldsmith-Pinkham | Docker isolation with Colima + Justfile |
| [Claude Code: My Workflow](https://psantanna.com/claude-code-my-workflow/) | Pedro Sant'Anna | Multi-agent verification, critic-fixer loops, persistent learning |
| [How I use Claude Code](https://www.youtube.com/watch?v=mZzhfPle9QU) | John Kim | Plan mode, parallel worktrees, hooks automation, subagent patterns |
| [Intelligent AI Delegation](https://arxiv.org/abs/2602.11865) | Academic paper | Agent failure handling, stall detection |
| [Intro to Multiagent Systems](https://www.linkedin.com/feed/update/urn:li:activity:7328490306763481088/) | Celeste Bean | Multiagent design patterns |
| [OWASP Top 10](https://owasp.org/www-project-top-ten/) | OWASP Foundation | Security reviewer vulnerability checklist |
| [frontend-slides](https://github.com/zarazhangrui/frontend-slides) | zarazhangrui | HTML presentation generator |
| [ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | nextlevelbuilder | UI/UX design intelligence skill |
| [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) | Anthropic (Prithvi Rajasekaran) | GAN-pattern evaluator gate, self-evaluation problem, harness simplification as models improve |
| [Superpowers](https://github.com/obra/superpowers) | Jesse Vincent (obra) | Anti-rationalization tables, red flag patterns, iron laws, evidence-based verification, TDD enforcement |

## License

MIT License. See [LICENSE](LICENSE) for details.
