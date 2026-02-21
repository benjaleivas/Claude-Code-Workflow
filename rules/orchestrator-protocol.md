# Orchestrator Protocol

This protocol auto-activates after any plan is approved. It sequences the existing workflow commands into a coherent post-plan execution loop.

## The Loop

### Step 0: BRANCH
Ensure work happens on a feature branch (see `branching-strategy.md`):
1. Check if in a worktree (`git rev-parse --git-common-dir` vs `--git-dir`) — if they differ, skip (worktrees are pre-branched)
2. Check current branch: `git branch --show-current`
3. If on main/master with a clean working tree:
   - `git pull --ff-only` (if remote exists, skip if offline)
   - `git checkout -b {type}/{description}` using the branch name from the plan
4. If already on the correct feature branch, continue
5. If on a wrong feature branch, warn the user before proceeding

Skip this step if the task is a quick fix (no plan mode, single-file change).

### Step 1: IMPLEMENT
Execute plan steps. Work through the blueprint systematically. If the plan has a spec section, reference it continuously during implementation.

### Step 2: VERIFY
Run the project's verification command (defined in project CLAUDE.md). If none exists, run the type checker or test suite at minimum. If verification fails, fix and re-verify before proceeding.

### Step 2b: VISUAL VERIFY (frontend/UI changes only)
If the plan involved UI changes:
1. **Desktop with preview**: If `.claude/launch.json` exists and preview tools are available, use `preview_*` tools (screenshot, snapshot, inspect, console_logs). Desktop auto-verifies after each edit, so confirm results here.
2. **CLI with Chrome**: If Chrome is connected (`/chrome`), suggest `/verify-ui` to visually check changes in a browser.
3. **Neither available**: Skip visual verification, note in the execution checklist.

Check for console errors, visual regressions, broken layouts.
Skip if: backend-only changes, no web target.

### Step 3: REVIEW
In Desktop: suggest the built-in diff view + **Review code** button for inline feedback. In CLI: suggest `/review` for uncommitted changes. For complex work (3+ files, architectural changes, security-sensitive code), suggest `/grill` instead. For automated fix iteration (critic finds issues, you fix, critic re-audits), suggest `/qa`.

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
- [x/~/ ] Feature branch created (or quick fix on main — justified)
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
- After `/pr`: In Desktop, suggest enabling **auto-fix** (Claude fixes failing CI checks) and **auto-merge** (squash merge when checks pass) from the CI status bar. In CLI, suggest monitoring CI manually or using `/fix-ci` if checks fail.
