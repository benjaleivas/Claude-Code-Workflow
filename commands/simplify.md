---
description: Clean and simplify code. Runs after every implementation. Checks structure, naming, patterns, and complexity.
---

Clean and simplify the code that was just written. Act as a code-quality craftsman.

## Mode Detection

Determine the scope of changes:
- Run `git diff --stat --name-only` to get changed files and line counts
- If **total changed lines <= 30** (quick fix): run in **lightweight mode** (skip subagent, analyze inline)
- If **total changed lines > 30** (non-trivial): run in **full mode** (use subagent per file)

## Checks

### Structure (simplification)
Scan each changed file and find:
- Overly complex conditionals that can be flattened or simplified
- Abstractions used only once — inline them
- Verbose patterns that have simpler equivalents in this language/framework
- Functions doing too many things — split them or simplify the flow
- Unnecessary defensive code — checks that can never fail given the calling context
- Premature abstractions — helpers/utilities for one-time operations
- Deep nesting (3+ levels) that can be flattened with early returns or guard clauses

### Naming
- Variables/functions/types that don't clearly communicate their purpose
- Inconsistent naming compared to the rest of the codebase (check surrounding code)
- Abbreviated names that hurt readability (acceptable: `i`, `e`, `ctx`, `req`, `res`)
- Boolean variables/functions that don't read as true/false questions (`isX`, `hasY`, `canZ`)

### Patterns
- Code that doesn't use the idiomatic pattern for this language/framework
- Reinventing something the standard library or project dependencies already provide
- Patterns inconsistent with how the rest of the codebase solves the same problem
  (run `grep -r` for similar patterns to compare)
- Magic numbers or strings that should be named constants

### Explicitness
- Implicit return types that should be annotated (especially on exported/shared functions)
- Hidden side effects in functions whose names suggest they are pure
- Unclear control flow (ternaries nested in ternaries, expressions doing too much)
- Default values that are non-obvious and should be documented by naming

### DRY (within the changeset only)
- Repeated patterns within the new code that should be extracted
- Copy-paste blocks with minor variations that should be parameterized
- (Cross-codebase duplication is `/techdebt`'s job — skip it here)

## Process

1. Find changed files: `git diff --name-only`
2. For each file, run the checks above
3. Categorize each finding:
   - **Auto-fix**: structural simplifications, idiomatic replacements, flatten nesting (safe, behavior-identical)
   - **Suggest**: naming changes, extractions, pattern replacements that alter signatures or public shape
4. Apply auto-fix changes directly
5. Present suggest changes as before/after diffs for user approval
6. Run typecheck (and tests if available) after changes to verify nothing broke
7. If verification fails, revert the last change and report

## Rules

- Only apply changes that maintain **identical behavior** — simplification, not modification
- Do NOT add features, comments, docstrings, or type annotations to code the user didn't ask to change
- Do NOT refactor code outside the changeset (that's `/techdebt`)
- Do NOT flag bugs or security issues (that's `/review` and `/grill`)
- Keep it fast: lightweight mode should complete in under 15 seconds
- If zero findings: report "Code is clean" and move on — don't manufacture findings

## Output

```
## /simplify: [N auto-fixed, M suggestions]

### Auto-fixed
- `file:line` — [description of change]

### Suggestions (need approval)
- `file:line` — [before] → [after] — [reason]

### Verification: PASS / FAIL
```

If no findings: `## /simplify: Clean — no changes needed`

Less code is almost always better code. Clear code is always better than clever code.
