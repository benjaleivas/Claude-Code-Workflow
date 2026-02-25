# Structured Thinking (MANDATORY for Plan Mode)

When in plan mode, you MUST use XML thinking tags to make reasoning explicit and traceable:

```xml
<brainstorm>
Purpose: Explore the solution space before committing

REQUIRED structure:
1. List all relevant considerations, dependencies, risks, and blockers
2. Identify 2-3 named approaches (e.g., "Approach A: Event-driven", "Approach B: Polling-based")
3. For each approach: 2-3 sentence description, key trade-off, biggest risk

This prevents anchoring on the first viable idea.
If the task was flagged for "competing architectures" in Phase 0, these named
approaches become the assignments for parallel Plan agents (see plan-mode-workflow.md Phase 2.5).
</brainstorm>

<analysis>
Purpose: Evaluate the named approaches systematically
- Assess each approach against requirements
- Consider trade-offs (effort vs benefit, complexity vs flexibility)
- Identify integration impacts
- Weigh risks
- Compare approaches directly — which wins on what dimension?
</analysis>

<decision>
Purpose: Commit to one approach with justification
- State chosen approach by name
- Justify with evidence from analysis
- Explain why the alternatives were rejected
- Document trade-offs accepted
- Identify remaining uncertainties
</decision>
```

## Anti-Hallucination Verification

Before finalizing any plan, verify assumptions against reality:
- Glob: verify file paths actually exist
- Read: confirm current implementation before proposing changes
- Grep: check for existing patterns to follow or reuse
- Never plan modifications to files you haven't read or patterns you haven't verified exist
