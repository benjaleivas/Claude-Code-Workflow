---
description: Review uncommitted changes. Returns SHIP/ALMOST/REWORK verdict.
---

Review uncommitted changes and suggest improvements.

## Current Changes

### Status
!`git status --short 2>/dev/null`

### Diff
!`git diff 2>/dev/null | head -500`

## Instructions

Review the changes shown above. For each modified file, analyze:
   - Is the change correct and complete?
   - Are there potential bugs or unhandled edge cases?
   - Does it follow the project's existing patterns and conventions?
   - Are there security concerns (injection, data exposure, auth)?
   - Is error handling adequate?
   - Any performance concerns?
Provide a concise summary:
   - **Good**: what looks solid
   - **Concerns**: specific issues with file path and line number
   - **Confidence**: one of these tiers:
     - **SHIP** — no concerns, ready to commit
     - **ALMOST** — minor issues, fix them then commit
     - **REWORK** — significant concerns, step back and rethink
   - **Suggestion**: recommended next step based on the confidence tier

Keep it brief. Don't repeat back the code — just flag issues and move on.
