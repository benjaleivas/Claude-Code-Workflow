# New Project Setup

When working in a project directory that has no CLAUDE.md, proactively offer to scaffold one. The project CLAUDE.md should be **project-specific only** — never duplicate instructions from the transversal file (they load automatically via `~/.claude/CLAUDE.md`).

## A Good Project CLAUDE.md Includes
- **Project**: one-line description
- **Tech Stack**: languages, frameworks, key dependencies
- **How to Run**: the exact command(s) to start the project
- **Directory Structure**: where things live
- **Key Patterns**: project-specific conventions (e.g., hook-driven data, offline-first)
- **Verification Command**: what to run after every change (e.g., `npx tsc --noEmit`, `pytest`)
- **Things Claude Should NOT Do**: project-specific guardrails

## CI Integration (if applicable)
If the project uses CI/CD, include a brief section:
- **CI Platform**: GitHub Actions / GitLab CI
- **Claude CI Job**: configured / not configured
- Note: CI-triggered Claude reads this CLAUDE.md — keep conventions explicit so CI jobs follow the same rules as local sessions.

## Do NOT Include in the Project CLAUDE.md
- Workflow principles (already in transversal)
- Slash command references (already in transversal)
- Code style preferences (already in transversal)
- Git preferences (already in transversal)
- Subagent patterns (already in transversal)

## Also Scaffold These Directories
When setting up a new project, create:
- `{project}/.claude/plans/` — for versioned plan artifacts
- `{project}/.claude/session-logs/` — for compression-resistant reasoning history
- `{project}/.claude/MEMORY.md` — with this header template:

```markdown
# Project Memory

## Key Facts
<!-- Immutable project facts go here -->

## Corrections Log
<!-- [LEARN:tag] entries go here. Only for corrections that would recur. -->
```
