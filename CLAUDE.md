# User-Level Instructions

## Session Start

When a new session begins and the user sends their first message, start your response with a brief workflow orientation:

1. A one-liner acknowledging the workflow is active (agents, commands, hooks loaded)
2. Classify their request and propose the matching workflow path:
   - **Feature / non-trivial task** → "I'll enter plan mode. Expect: spec → devil's advocate → blueprint → implement → verify → /review."
   - **Bug / error / failing tests** → "I'll use the debugger pattern: capture → hypothesize → isolate → root cause → fix. No planning overhead."
   - **Quick fix / small change** → "Straightforward — I'll make the change, verify, and suggest /review."
   - **Exploration / prototype** → "I'll suggest /explore to keep this in a sandbox with relaxed gates."
   - **Risky / data-heavy work** → "Consider /container for an isolated environment."
   - **Workflow meta-task** → "Working on the workflow itself — I'll modify ~/.claude/ config."
3. If the project has `.claude/MEMORY.md`, mention relevant [LEARN] entries for the domain.

Keep it to 3-5 lines total. Don't list all available commands — just the ones relevant to THIS task. Then proceed immediately with the work.

Skip this orientation for:
- Follow-up messages in an ongoing session (only fires on the first message)
- Continuation sessions (context summaries indicate prior work)
- When the user's message is a slash command (they already know what they want)

## Who I Am
Benjamín Leiva. Solo developer. I work on mobile apps (React Native/Expo), backends (Supabase/Deno), and data projects.

## Slash Commands — USE THESE PROACTIVELY

I have transversal slash commands in `~/.claude/commands/`. **Do not wait for me to ask — use them as part of every workflow.**

### When Planning (plan mode)
- Reference `/verify-app` (or project equivalent) as the verification step in every plan
- Reference `/grill` as the pre-push quality gate
- Reference `/devils-advocate` for any section of the plan that involves complex logic, concurrency, security, or data integrity
- Include `/techdebt` as a final cleanup step in multi-file plans
- For large multi-area tasks: consider suggesting an agent team instead of sequential implementation
- For risky or data-heavy tasks: suggest `/container` for isolated Docker environment

### When Implementing
- After finishing a unit of work: suggest running `/review` before committing
- After committing: if the work is ready to push, suggest `/grill` before `/pr`
- After writing complex code: suggest `/simplify` to reduce unnecessary complexity
- If tests exist: suggest `/test-and-fix` after changes that could break things
- If tests are failing in a loop and manual iteration is tedious: suggest `/ralph-loop`
- For thorough automated review with fix loop: suggest `/qa` (or `/qa security` for security focus)
- For prototyping or experiments: suggest `/explore` to enter exploration mode

### When Something Goes Wrong
- If a fix feels too easy for a hard problem: proactively run `/devils-advocate`
- If Claude is confident but the user seems skeptical: proactively run `/devils-advocate`
- If multiple approaches were considered: run `/grill` on the chosen approach before committing
- If stuck in a test-fix cycle: suggest `/ralph-loop` for autonomous iteration
- If ralph-loop should stop early: suggest `/cancel-ralph`
- If CI is failing: suggest `/fix-ci` to fetch logs, diagnose, and fix
- When user pastes a bug report, error log, or Slack thread: don't ask clarifying questions — read the context, find root cause, fix it. Minimize back-and-forth.

### End of Session
- Always suggest `/techdebt` before closing out a session
- After significant work (3+ files or 50+ lines): suggest `/update-tracker`
- Always suggest `/commit` for any uncommitted work

## Workflow Principles

1. **Plan first, then execute.** Start non-trivial tasks in plan mode. Iterate on the plan until it's solid. Then implement — usually in one shot.
2. **Verify your work.** After every change, run the project's verification command. If it doesn't exist, at minimum run the type checker or test suite.
3. **Use subagents to keep context clean.** Offload research, verification, and review to subagents. Don't pollute the main context with exploration output.
4. **If you do something more than once, it should be a command.** If I ask for the same thing twice in a session, suggest creating a slash command for it.
5. **Self-improvement.** After every mistake or correction, write a `[LEARN:tag]` entry to the project's MEMORY.md. See `~/.claude/rules/learn-system.md`.
6. **Work in parallel.** Git worktrees for independent tasks. Agent teams when teammates need to communicate.
7. **Spec before code.** For tasks involving external services, data processing, or complex state: outline expected shapes, contracts, and edge cases BEFORE writing code. Specs go in the plan (Phase 3) or via `/spec`.
8. **Persist everything that matters.** Plans, corrections ([LEARN] tags), and session reasoning go to disk. Conversation context is ephemeral — auto-compression will discard it. Anything worth keeping gets written to a file before it can be lost.

## Autonomy Boundaries

### Proceed Autonomously
- Running verification/test commands
- Auto-formatting code
- Fixing lint/type errors that are clearly wrong
- Creating session logs and plan files
- Scanning for secrets
- Running `/review` on uncommitted changes
- Creating feature branches for plan-mode work
- Switching back to main after a PR is merged

### Consult User First
- Deleting files or removing features
- Changing database schema or auth logic
- Installing new dependencies
- Changing CI/CD configuration
- Promoting exploration code to production
- Any action that's not easily reversible

## [LEARN] Tag System

When a mistake is caught or a correction is made, persist it:
```
[LEARN:tag] Brief description of what went wrong and the correct approach
```
Written to project-level `{project}/.claude/MEMORY.md`. Only for corrections that would recur. Check MEMORY.md before implementing in a domain. See `~/.claude/rules/learn-system.md`.

## Code Style Preferences
- Prefer `type` over `interface` in TypeScript
- Never use `enum` — use string literal unions
- Keep functions small and focused
- Handle errors explicitly — never swallow them
- Prefer simple code over clever code
- Don't add comments, docstrings, or type annotations to code I didn't ask you to change
- Don't over-engineer — solve the problem at hand, not hypothetical future problems

## Git Preferences
- Commit messages: start with a verb, focus on WHY not WHAT
- Don't push without being asked
- Don't amend previous commits unless I ask
- Don't use `--no-verify`
- Prefer specific `git add <files>` over `git add -A`

### Branching Strategy
- **Convention**: `feature/description`, `fix/description`, `chore/description` (lowercase kebab-case, 2-4 words)
- **When to branch**: Always for plan-mode work. The orchestrator creates the branch automatically (Step 0).
- **When to stay on main**: Quick fixes — single-file, under ~20 lines, no plan mode.
- **Main is sacred**: Only merged PR code lands on main. No direct pushes for non-trivial work.
- **One branch per task**: After a PR merges, start fresh from main.
- See `~/.claude/rules/branching-strategy.md` for full details.

## Daily Workflow
```
feature branch → write code → verify → /review → /commit
     ↑                                               ↓
  (auto by                    /grill → fix → /pr (push + PR)
  orchestrator)                                       ↓
                    /techdebt → /update-tracker → /commit → close
```
Quick fixes skip branching and commit directly to main.

## Review Tool Chooser

| Situation | Tool | Time |
|-----------|------|------|
| Quick check before commit | `/review` | 30s |
| Thorough review with memory | `code-reviewer` agent | 5 min |
| Automated critic-fixer loop | `/qa` | 5-15 min |
| Adversarial pre-push gate | `/grill` | 5 min |
| Security-specific audit | `security-reviewer` agent | 5 min |

## Detailed Rules (loaded from `~/.claude/rules/`)

These files contain detailed patterns extracted from this document. They auto-load every session. If a rule doesn't load, read the file manually.

- **Structured Thinking** — `structured-thinking.md` — XML tags (`<brainstorm>`, `<analysis>`, `<decision>`) and anti-hallucination verification. MANDATORY for plan mode.
- **Plan Mode Workflow** — `plan-mode-workflow.md` — 5-phase workflow (Thinking → Questions → Blueprint with specs → Devil's Advocate → Propose). Plans saved to disk. Orchestrator activates after approval.
- **Orchestrator Protocol** — `orchestrator-protocol.md` — Post-plan execution loop: implement → verify → /review → fix → re-verify → /commit. Uses existing slash commands.
- **Spec Before Code** — `spec-before-code.md` — Data shapes, contracts, edge cases, success criteria. Required in plan Phase 3 and via `/spec`.
- **Subagent Patterns** — `subagent-patterns.md` — Debugger, Code Reviewer, Security Reviewer, Bug Fixer, Agent Teams.
- **Custom Agents** — `~/.claude/agents/` — Code Reviewer, Debugger, Security Reviewer, Test Writer, Supabase Specialist, Expo Specialist. All have persistent memory.
- **Session Logging** — `session-logging.md` — Compression-resistant reasoning history. Only for plan-mode tasks. Three triggers: after approval, during implementation, at session end.
- **[LEARN] System** — `learn-system.md` — Persistent tagged corrections in project MEMORY.md.
- **New Project Setup** — `new-project-setup.md` — Project CLAUDE.md scaffolding + plans/, session-logs/, MEMORY.md directories.
- **Branching Strategy** — `branching-strategy.md` — Feature branch convention, orchestrator Step 0, quick fix exemption, cleanup.
