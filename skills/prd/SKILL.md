---
name: prd
description: Generate a Product Requirements Document from a problem statement. Structures requirements, user stories, and constraints before planning.
---

# PRD Generator

Generate a Product Requirements Document that captures WHAT to build and WHY, before entering plan mode for HOW.

## Workflow

1. **Ask about the problem**: Use AskUserQuestion to understand:
   - What pain point or opportunity does this address?
   - Who is the target user?
   - What does success look like?

2. **Generate PRD** using the template below. Fill in what you can from the conversation, mark unknowns as `[TBD]`.

3. **Review with user**: Present the PRD and iterate until requirements are clear and complete.

4. **Save**: Write to `{project}/.claude/plans/PRD-YYYY-MM-DD_description.md`

5. **Transition to planning**: Suggest entering plan mode with the PRD as input context.

## Template

```markdown
# PRD: [Title]

## Problem Statement
[What problem are we solving? Who has this problem? Why does it matter now?]

## User Stories
- As a [user type], I want [capability] so that [benefit]

## Requirements

### P0 (Must Have)
- [ ] ...

### P1 (Should Have)
- [ ] ...

### P2 (Nice to Have)
- [ ] ...

## Technical Constraints
[Platform, performance, compatibility, security requirements]

## Out of Scope
[Explicitly list what this does NOT include]

## Success Criteria
[How do we know this is done? Measurable outcomes]

## Open Questions
[Unresolved decisions that need input]
```

## Guidelines

- PRDs capture requirements (what/why). Plans capture implementation (how).
- A PRD should fit on one screen. If it's longer, the scope is too big — split it.
- PRDs are reference documents, not auto-loaded rules. They live in `.claude/plans/`.
- This skill is opt-in only. It is NOT part of the standard planning workflow — use it when you want structured requirements before diving into plan mode.
