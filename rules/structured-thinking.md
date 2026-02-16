# Structured Thinking (MANDATORY for Plan Mode)

When in plan mode, you MUST use XML thinking tags to make reasoning explicit and traceable:

```xml
<brainstorm>
Purpose: Generate options without judgment
- List all relevant considerations
- Identify dependencies between components
- Note potential risks and blockers
- Consider alternative approaches
</brainstorm>

<analysis>
Purpose: Evaluate options systematically
- Assess each option against requirements
- Consider trade-offs (effort vs benefit, complexity vs flexibility)
- Identify integration impacts
- Weigh risks
</analysis>

<decision>
Purpose: Commit to approach with justification
- State chosen approach clearly
- Justify with evidence from analysis
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
