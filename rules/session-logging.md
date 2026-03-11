# Session Logging (Plan-Mode Tasks Only)

Session logs record WHY decisions were made, not just WHAT changed. They survive context compression because they live on disk. Git commits record WHAT. Session logs record WHY.

**Only activates for tasks that enter plan mode.** Quick fixes that skip planning also skip session logs.

## Three Logging Triggers

### 1. After Blueprint (Phase 3)
Create `{project}/.claude/session-logs/YYYY-MM-DD_description.md` with:
- Goal and plan summary
- Explored approaches from Phase 1 (brainstorm results)
- Clarifying Q&A from Phase 2
- Rationale for chosen approach (including rejected alternatives)
- Key constraints and assumptions

Create this BEFORE devil's advocate (Phase 4), not after approval.
Compaction can hit during planning — this is the safety net.

### 2. During Implementation
Append to the session log as you work. Every time:
- A design decision is made
- A problem is discovered
- The approach deviates from the plan

Write a 1-3 line entry immediately. This is the most important trigger: decisions that live only in conversation WILL be lost to compression.

### 3. At Session End
Add a final section with:
- What was accomplished
- Open questions
- Unresolved issues
- Next steps for future sessions

## Recovery
If context is lost after compression, point Claude to the session log:
> "Read .claude/session-logs/YYYY-MM-DD_description.md — that's our current session."

## Relationship to /update-tracker
Session logs capture reasoning during the session. `/update-tracker` captures a structured summary at the end. Both are valuable — session logs are the detailed journal, `/update-tracker` is the executive summary.
