# Plan Mode Workflow (5 Phases)

For EVERY non-trivial plan, follow this mandatory workflow:

## Phase 1: Structured Thinking
Use XML tags (`<brainstorm>`, `<analysis>`, `<decision>`) to explore the problem space before designing anything. The `<brainstorm>` tag MUST list 2-3 named approaches with trade-offs — see `~/.claude/rules/structured-thinking.md` for tag definitions. If the task was flagged for "competing architectures," these named approaches become the assignments for parallel agents in Phase 2.5.

## Phase 2: Clarifying Questions
Use AskUserQuestion to resolve ambiguities BEFORE designing:
- Scope boundaries and edge cases
- Priorities and constraints
- Implementation preferences

Skip ONLY if user provided exhaustive specs (document why in the plan).

## Phase 2.5: Architecture Competition (only when flagged as ambiguous)

When the task was classified as "competing architectures" in Phase 0:

1. **Main session explores** (Phase 1): The `<brainstorm>` identifies 2-3 genuinely different architectural directions. Each must be a fundamentally different approach, not variations of the same idea.

2. **Resolve questions first** (Phase 2): All clarifying questions must be answered before spawning agents, since agents cannot ask follow-ups.

3. **Spawn 2-3 parallel Plan agents** (one per approach). Each receives:
   - Full exploration context from Phase 1
   - Answers to all clarifying questions from Phase 2
   - Their assigned architectural direction
   - Instruction to build a full blueprint arguing FOR their approach
   - Awareness of the other approaches (so they argue against them)

4. **Each agent delivers**:
   - Approach name and 2-sentence summary
   - Why this approach is best (explicit argument)
   - Why the other approaches are worse (explicit counterarguments)
   - Full spec section (data shapes, contracts, edge cases)
   - Files to modify with specific changes
   - Verification strategy
   - Biggest risk and mitigation

5. **Main session presents a comparison table**:
   | Dimension | Plan A | Plan B | Plan C |
   |-----------|--------|--------|--------|
   | Approach  | ...    | ...    | ...    |
   | Complexity| ...    | ...    | ...    |
   | Risk      | ...    | ...    | ...    |
   | Files     | ...    | ...    | ...    |

6. **User picks** (or synthesizes): e.g., "Plan B, but use Plan A's data model."

7. **Main session synthesizes** the final blueprint incorporating the user's choice. Proceed to Phase 4 (Devil's Advocate) on the synthesized plan.

**Artifact persistence**: Save all plans to disk alongside the final plan:
- `{project}/.claude/plans/YYYY-MM-DD_description.md` (final)
- `{project}/.claude/plans/YYYY-MM-DD_description_alt-A.md` (rejected)
- `{project}/.claude/plans/YYYY-MM-DD_description_alt-B.md` (rejected)

If the task was NOT flagged for competing architectures, skip this phase entirely.

## Phase 3: Blueprint

**Competing architectures path**: Phase 2.5 already produced the blueprint. Skip to Phase 4.

**Standard path**: Create a detailed implementation plan. The `<brainstorm>` from Phase 1 already required 2-3 named approaches — the `<decision>` tag justifies the chosen one. Include:
- **Spec section (REQUIRED)**: data shapes, API contracts, DB constraints, external service behaviors, edge cases, success criteria. See `~/.claude/rules/spec-before-code.md`.
- Files to modify with specific changes
- Step-by-step execution sequence
- Verification steps for each phase
- Rollback strategy for risky changes
- **Branch name**: `{type}/{description}` following the branching convention (see `branching-strategy.md`)
- **Simplify scope note** (optional): if the plan intentionally uses verbose patterns for documented reasons (e.g., readability, explicit error handling), note it here so Step 2c (`/simplify`) does not undo deliberate choices

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
