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

## Preview Server Configuration (web projects)
For projects with a dev server, create `.claude/launch.json` so Desktop preview and `preview_*` tools can auto-verify UI changes:

```json
{
  "version": "0.0.1",
  "configurations": [
    {
      "name": "dev",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000
    }
  ]
}
```

Adjust `runtimeExecutable`, `runtimeArgs`, and `port` to match the project. For monorepos with multiple servers, add multiple configurations. Set `"autoVerify": false` at the top level to disable auto-verification after every edit.

## Path-Specific Rules
Project-level rules in `.claude/rules/` can use YAML frontmatter with a `paths` field to load conditionally:

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Conventions
These rules only load when working on API files.
```

Use this for directory-scoped conventions (e.g., API rules, component rules, test rules).

## CLAUDE.md Imports
Project CLAUDE.md files can import content from other files using `@path` syntax:

```markdown
@docs/api-conventions.md
@docs/database-patterns.md
```

This keeps CLAUDE.md lean while referencing detailed docs. Imports are recursive (max depth 5) and paths resolve relative to the containing file.

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
