# Orchestrator Protocol

This protocol auto-activates after any plan is approved. It sequences the existing workflow commands into a coherent post-plan execution loop.

## The Loop

### Step 1: IMPLEMENT
Execute plan steps. Work through the blueprint systematically. If the plan has a spec section, reference it continuously during implementation.

### Step 2: VERIFY
Run the project's verification command (defined in project CLAUDE.md). If none exists, run the type checker or test suite at minimum. If verification fails, fix and re-verify before proceeding.

### Step 2b: VISUAL VERIFY (frontend/UI changes only)
If the plan involved UI changes and Chrome is available (`/chrome` connected):
- Suggest `/verify-ui` to visually check the changes in a browser
- Check for console errors, visual regressions, broken layouts
- Skip if: backend-only changes, no web target, Chrome not connected

### Step 3: REVIEW
Suggest `/review` for uncommitted changes. For complex work (3+ files, architectural changes, security-sensitive code), suggest `/grill` instead. For automated fix iteration (critic finds issues, you fix, critic re-audits), suggest `/qa`.

### Step 4: FIX
Address issues found in review. Prioritize: critical > major > minor. Don't fix style nits during this step — those go to `/techdebt`.

### Step 5: RE-VERIFY
Run verification again after fixes. If it fails, loop back to Step 4.

### Step 6: REPORT
Present a summary to the user:
- What was implemented
- Verification results
- Review findings and how they were addressed

**MANDATORY**: End every report with the **Execution Checklist**:

```
### Execution Checklist
- [x/~/ ] Verification passed (command: `...`)
- [x/~/ ] `/review` run on changes
- [x/~/ ] `/grill` run (if 3+ files or architectural/security changes)
- [x/~/ ] All review findings addressed
- [x/~/ ] `/verify-ui` run (if frontend/UI changes and Chrome available)
- [x/~/ ] `/commit` suggested or completed
- [x/~/ ] `/techdebt` suggested (if multi-file plan)
- [x/~/ ] `/update-tracker` suggested (if 3+ files or 50+ lines)
- [x/~/ ] Session log updated (if plan-mode task)
```

Legend: `[x]` = done, `[~]` = not applicable / skipped with justification, `[ ]` = not done.

If any box is `[ ]` without justification, go back and complete it before closing.

## Important Notes
- This protocol uses your existing slash commands — it doesn't replace them
- Verification pass/fail is the quality gate (no numeric scoring)
- If stuck at any step, surface the blocker to the user instead of spinning
- For multi-session work, update the session log at each step transition
