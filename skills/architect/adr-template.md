# Architecture Decision Record — Template

Use this template when producing ADRs. Every section is required.

## ADR: [Decision Title]

### Context

[What is the situation? What forces are at play? Reference specific files, patterns, and constraints from the codebase.]

### Decision

[What was decided and why. Be specific about components, boundaries, and data flow. Name the chosen approach explicitly.]

### Consequences

**Positive**:
- [What improves — be specific]

**Negative**:
- [What gets harder or is accepted as a trade-off — be honest]

### Alternatives Considered

#### Option A: [Name]
- **Summary**: [2-3 sentences describing the approach]
- **Strengths**: [What this option does well]
- **Rejected because**: [Specific reason — not "it's worse", but WHY it's worse for this context]

#### Option B: [Name]
- **Summary**: [2-3 sentences describing the approach]
- **Strengths**: [What this option does well]
- **Rejected because**: [Specific reason]

*(Add more options if evaluated)*

### Trade-offs Accepted

[Explicit acknowledgment of what was sacrificed and why it's acceptable in the current context. Every architectural decision trades something — name it.]

### Implementation Guidance

- **File structure**: [Key files/directories to create or modify]
- **Key abstractions**: [New types, interfaces, or patterns to introduce]
- **Integration points**: [Where the new design connects to existing code]
- **Migration path**: [If replacing existing code, how to transition safely]

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [Biggest risk] | [H/M/L] | [H/M/L] | [Specific mitigation] |
| [Second risk] | [H/M/L] | [H/M/L] | [Specific mitigation] |

### Data Flow

*(Include a text-based diagram when the design involves 2+ components)*

```
[Component A] --request--> [Component B] --query--> [Database]
                                         <--data---
              <--response--
```
