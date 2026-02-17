# Plan Mode Workflow (5 Phases)

For EVERY non-trivial plan, follow this mandatory workflow:

## Phase 1: Structured Thinking
Use XML tags (`<brainstorm>`, `<analysis>`, `<decision>`) to explore the problem space before designing anything. See `~/.claude/rules/structured-thinking.md` for tag definitions.

## Phase 2: Clarifying Questions
Use AskUserQuestion to resolve ambiguities BEFORE designing:
- Scope boundaries and edge cases
- Priorities and constraints
- Implementation preferences

Skip ONLY if user provided exhaustive specs (document why in the plan).

## Phase 3: Blueprint
Create a detailed implementation plan including:
- **Spec section (REQUIRED)**: data shapes, API contracts, DB constraints, external service behaviors, edge cases, success criteria. See `~/.claude/rules/spec-before-code.md`.
- Files to modify with specific changes
- Step-by-step execution sequence
- Verification steps for each phase
- Rollback strategy for risky changes
- **Branch name**: `{type}/{description}` following the branching convention (see `branching-strategy.md`)

**Save to disk**: Write the plan to `{project}/.claude/plans/YYYY-MM-DD_description.md`. This makes it recoverable after compression and across sessions.

## Phase 4: Devil's Advocate
ALWAYS run `/devils-advocate` (or invoke the pattern via subagent) before finalizing the plan. Address all findings:
- **ACCEPTED**: update plan with mitigation
- **DISMISSED**: provide specific evidence why it doesn't apply
- **DEFERRED**: track for future work

## Phase 5: Propose
Present the plan only after phases 1-4 are complete. After user approval, the orchestrator protocol activates automatically (see `~/.claude/rules/orchestrator-protocol.md`).

**MANDATORY**: Every plan output must end with the **Planning Checklist** below. After implementation, the orchestrator report must include the **Execution Checklist**.

```
### Planning Checklist
- [x/~/ ] Structured thinking (`<brainstorm>`, `<analysis>`, `<decision>`)
- [x/~/ ] Clarifying questions (or documented why skipped)
- [x/~/ ] Spec section (data shapes, contracts, edge cases, success criteria)
- [x/~/ ] Plan saved to disk (`{project}/.claude/plans/...`)
- [x/~/ ] Devil's advocate (findings: N accepted, N dismissed, N deferred)
- [x/~/ ] Verification strategy defined
```

Legend: `[x]` = done, `[~]` = partially done / skipped with justification, `[ ]` = not done.

If any box is `[ ]`, the plan is incomplete — go back and finish it before proposing.
