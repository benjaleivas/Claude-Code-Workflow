---
description: Automated quality assurance loop. Read-only critic finds issues, you fix them, critic re-audits. Max 3 rounds.
---

# Quality Assurance Loop

Run an automated critic-fixer loop on uncommitted changes. A read-only reviewer agent identifies issues by severity, you fix the critical and major ones, then the reviewer re-audits. Repeat until clean or 3 rounds max.

## Arguments

- No argument: use the `code-reviewer` agent as critic (default — functional correctness)
- `security`: use the `security-reviewer` agent as critic (security-focused)

## The Loop

### For each round (max 3):

**CRITIC phase:**
1. Spawn the appropriate reviewer agent (code-reviewer or security-reviewer) as a subagent
2. Pass it the current `git diff` output and ask it to review all changes
3. Collect findings categorized as CRITICAL, MAJOR, or MINOR

**Decision gate:**
- If NO CRITICAL or MAJOR findings → **PASS** — report and exit the loop
- If CRITICAL or MAJOR findings exist → continue to FIXER phase

**FIXER phase:**
4. For each CRITICAL finding: fix it immediately
5. For each MAJOR finding: fix it
6. Do NOT fix MINOR findings — report them but leave them for `/techdebt`
7. After all fixes: run the project's verification command
8. If verification fails → **BLOCKED** — report what broke and stop

**Next round:**
9. Go back to CRITIC phase with the updated code

### Exit conditions

| Result | Meaning | What to report |
|--------|---------|---------------|
| **PASS** | No CRITICAL or MAJOR issues remain | List of MINOR findings (if any), total rounds taken |
| **PARTIAL** | 3 rounds done, some issues remain | List of unresolved findings, what was fixed |
| **BLOCKED** | Verification failed after a fix | What broke, which fix caused it, rollback suggestion |

## Output Format

```
## QA Result: [PASS / PARTIAL / BLOCKED]

### Round Summary
- Round 1: [N] critical, [N] major, [N] minor → fixed [N] issues
- Round 2: [N] critical, [N] major, [N] minor → fixed [N] issues
(etc.)

### Resolved
- [file:line] Description — fixed in round N

### Remaining (MINOR — deferred to /techdebt)
- [file:line] Description

### Verification
- Command: `[verification command]`
- Result: PASS / FAIL
```

## Important Rules

- The CRITIC agent is always read-only (no Write/Edit tools). It reports, never modifies.
- The FIXER (you, in the main session) does the actual code changes. This prevents self-approval bias.
- Only fix CRITICAL and MAJOR. MINOR issues are reported but left alone.
- **Severity mapping**: In code-reviewer mode, fix CRITICAL + MAJOR. In security mode (`/qa security`), fix CRITICAL + HIGH (the security-reviewer uses CRITICAL/HIGH/MEDIUM/LOW per security conventions).
- Always run verification after each round of fixes.
- If a fix introduces a new issue, the next critic round will catch it.
- After the loop completes, suggest `/commit` if PASS, or `/review` if PARTIAL.
