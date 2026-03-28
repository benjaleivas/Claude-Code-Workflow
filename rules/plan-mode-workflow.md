# Plan Mode Workflow (5 Phases)

For EVERY non-trivial plan, follow this mandatory workflow:

## Phase 1: Structured Thinking

### Scope Gear (standard planning only — not competing architectures)

Before brainstorming approaches, select a scope gear. This changes the reviewer's posture for the entire plan:

| Gear | Posture | When to use |
|------|---------|-------------|
| **EXPANSION** | "What would make this 10x better for 2x effort?" Find the 10-star product hiding in the request. Push ambition, identify delight opportunities, map the dream state. | New features, product direction decisions, early-stage product areas |
| **HOLD SCOPE** | Accept the plan's scope as given. Maximize rigor — every failure mode, edge case, and integration point gets defensive treatment. | Bug fixes, well-scoped features, incremental improvements |
| **REDUCTION** | "What's the absolute minimum that delivers user value?" Everything else defers. Surgeon's mindset — ruthless about cutting scope while preserving core outcome. | Tight deadlines, MVP features, unblocking work, when scope is creeping |

Default to HOLD SCOPE if unclear. The user can override via AskUserQuestion in Phase 0 (see `session-lifecycle.md`).

The scope gear persists through all 5 phases — brainstorm, questions, blueprint, devil's advocate, and proposal should all reflect the selected gear.

### Brainstorming

Use XML tags (`<brainstorm>`, `<analysis>`, `<decision>`) to explore the problem space before designing anything. The `<brainstorm>` tag MUST list 2-3 named approaches with trade-offs — see `~/.claude/rules/structured-thinking.md` for tag definitions. If the task was flagged for "competing architectures," these named approaches become the assignments for parallel agents in Phase 2.5.

## Phase 2: Clarifying Questions (MANDATORY)

Claude MUST ask at least one round of clarifying questions via AskUserQuestion. This phase cannot be self-skipped.

1. Draft 2-4 questions covering:
   - Scope boundaries and edge cases
   - Priorities and constraints
   - Implementation preferences
   - Acceptance criteria

2. Present via AskUserQuestion (mandatory — not optional).

3. After receiving answers, evaluate: "Are there remaining ambiguities that could lead to rework?"
   - If yes: ask another round of questions.
   - If no: ask user to confirm scope is clear (via AskUserQuestion with a "Scope is clear, proceed to blueprint" option).

4. User confirms → proceed to Phase 3.

**Exit condition**: User explicitly confirms scope is clear. Not Claude's judgment alone.

**Planning Checklist enforcement**: If no AskUserQuestion was called during Phase 2, the checklist item MUST be `[ ]` (not done), which blocks the plan from being proposed.

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
- **What Already Exists**: Before proposing new code, list existing functions, utilities, components, and patterns that solve sub-problems of this task. Reference file paths. This prevents reinventing what the codebase already has.
- **NOT in Scope**: Explicitly document work that was considered but deferred. Each item gets a one-line rationale for why it's deferred. This is stronger than a vague "future work" section — it's a conscious scope boundary.
- **Spec section (REQUIRED)**: data shapes, API contracts, DB constraints, external service behaviors, edge cases, success criteria. See `~/.claude/rules/spec-before-code.md`.
- **Locked interfaces** (for critical sections): Shared contracts must include **exact type definitions and function signatures** in the plan — not just descriptions. Examples: data models, API request/response types, auth flow types, component prop types for shared components, hook return types, context shapes. Implementation fills in the bodies, but interfaces are locked at plan time. This prevents implementation drift on the pieces that matter most. Enforced by implementer discipline (not the evaluator gate — see orchestrator Step 2f note). Skip for changes that don't export types or functions consumed by other modules.
- **Note on acceptance criteria format**: The spec section's success criteria (required by `spec-before-code.md`) double as the acceptance contract for the evaluator gate (orchestrator Step 2f). Write them as **binary pass/fail** criteria specific enough that an agent with access to the running app can verify without ambiguity. Bad: "auth works." Good: "POST /api/login with valid credentials returns 200 + session cookie; invalid credentials returns 401 with error message." There is one source of truth — the spec's success criteria — not a separate "contract."
- Files to modify with specific changes
- Step-by-step execution sequence
- Verification steps for each phase
- Rollback strategy for risky changes
- **Branch name**: `{type}/{description}` following the branching convention (see `branching-strategy.md`)
- **Dream State** (EXPANSION gear or major features): Map `CURRENT STATE → THIS PLAN → 12-MONTH IDEAL`. What does this system look like in a year? How does this plan move toward that vision? Skip for HOLD SCOPE / REDUCTION gear unless the feature is foundational.
- **Simplify scope note** (optional): if the plan intentionally uses verbose patterns for documented reasons (e.g., readability, explicit error handling), note it here so Step 2c (`/simplify`) does not undo deliberate choices
- **ADR section** (for architectural decisions): when the plan involves choosing between fundamentally different approaches (database design, service architecture, state management strategy), document the decision in ADR format:

### Architecture Decision Record (ADR) — Template
```markdown
## ADR: [Decision Title]

### Context
[What is the situation? What forces are at play?]

### Decision
[What was decided and why]

### Consequences
**Positive**: [What improves]
**Negative**: [What gets harder or is accepted as a trade-off]

### Alternatives Considered
[Brief summary of rejected approaches and why]

### Trade-offs Accepted
[Explicit acknowledgment of what was sacrificed]
```

Use ADR format when the `<decision>` tag from Phase 1 involves significant architectural trade-offs. For simple implementation plans, the standard `<decision>` justification is sufficient — don't add ADR overhead to every plan.

**Save to disk**: Write the plan to `{project}/.claude/plans/YYYY-MM-DD_description.md`. This makes it recoverable after compression and across sessions.

**Create session log now**: After saving the plan, immediately create the session log (`{project}/.claude/session-logs/YYYY-MM-DD_description.md`) with brainstorm results, clarifying Q&A, and rationale. This MUST happen before Phase 4 — compaction can hit during planning. See `session-logging.md` Trigger 1.

## Phase 4: Devil's Advocate (AUTO-RUN, before user sees plan)
ALWAYS run `/devils-advocate` (or invoke the pattern via subagent) BEFORE presenting the plan to the user. The user should never see a plan that hasn't been stress-tested.

Address all findings:
- **ACCEPTED**: update the blueprint with mitigation. Mark what changed.
- **DISMISSED**: provide specific evidence why it doesn't apply.
- **DEFERRED**: track for future work.

The findings become a mandatory section in the Phase 5 output (see below).

## Phase 5: Propose
Present the plan only after phases 1-4 are complete. The plan output MUST include:

1. The blueprint (from Phase 3, revised per Phase 4 findings)
2. A **Devil's Advocate Findings** section showing:
   - What was challenged
   - What was ACCEPTED (and how the plan changed)
   - What was DISMISSED (and why)
   - What was DEFERRED (and where it's tracked)
3. The Planning Checklist

After user approval, the orchestrator protocol activates automatically (see `~/.claude/rules/orchestrator-protocol.md`).

**MANDATORY**: Every plan output must end with the **Planning Checklist** below. After implementation, the orchestrator report must include the **Execution Checklist**.

```
### Planning Checklist
- [x/~/ ] Structured thinking (`<brainstorm>`, `<analysis>`, `<decision>`)
- [x/~/ ] Clarifying questions (MANDATORY — AskUserQuestion called, user confirmed scope)
- [x/~/ ] Spec section (data shapes, contracts, edge cases, success criteria as binary pass/fail for evaluator gate)
- [x/~/ ] Locked interfaces (exact types/signatures for critical sections, or N/A)
- [x/~/ ] Plan saved to disk (`{project}/.claude/plans/...`)
- [x/~/ ] Devil's advocate (findings: N accepted, N dismissed, N deferred)
- [x/~/ ] Verification strategy defined
- [x/~/ ] TODO.md entry format prepared (type, scope, branch)
```

Legend: `[x]` = done, `[~]` = partially done / skipped with justification, `[ ]` = not done.

If any box is `[ ]`, the plan is incomplete — go back and finish it before proposing.
