# Orchestrator Protocol

This protocol auto-activates after any plan is approved. It sequences the existing workflow commands into a coherent post-plan execution loop.

## The Loop

### Step 0: BRANCH
Ensure work happens on a feature branch (see `branching-strategy.md`):
1. **Conductor workspace?** Check `$CONDUCTOR_WORKSPACE_PATH`. If set, branch already exists (Conductor created it). Rename with `git branch -m benjaleivas/{description}` if the current name doesn't match the plan. Skip to Step 1.
2. Check if in a worktree (`git rev-parse --git-common-dir` vs `--git-dir`) — if they differ, skip (worktrees are pre-branched)
3. Check current branch: `git branch --show-current`
4. If on main/master with a clean working tree:
   - `git pull --ff-only` (if remote exists, skip if offline)
   - `git checkout -b {type}/{description}` using the branch name from the plan
5. If already on the correct feature branch, continue
6. If on a wrong feature branch, warn the user before proceeding

Skip this step if the task is a quick fix (no plan mode, single-file change).

### Step 0a: RENAME WORKTREE / BRANCH
**Conductor workspace**: Branch rename handled in Step 0 (via `git branch -m`). Skip this step.

**Git worktree**: If working in a worktree (detected in Step 0), rename it to match the plan:
1. Derive a descriptive name from the plan's branch name or description (e.g., `feature/dark-mode-toggle` → `dark-mode-toggle`)
2. Compute the new path: replace the last path segment of the current worktree path
3. Run: `git worktree move "$(pwd)" "<new-path>"`
4. `cd` into the new path (the old path is no longer valid)
5. Confirm with `git worktree list` and `pwd`

Skip if: not in a worktree, or the worktree name already matches the plan.

### Step 0b: TRACK (deferred to cleanup)
Do NOT edit TODO.md on feature branches — it causes merge conflicts with parallel worktree sessions.
Instead, note the task metadata for later:
- Type/scope from the plan's branch name
- One-line goal from the plan
- Branch name

TODO.md is updated on main during Phase 5 cleanup (after PR merge). See `session-lifecycle.md`.

### Step 1: IMPLEMENT
Execute plan steps. Work through the blueprint systematically. If the plan has a spec section, reference it continuously during implementation.

### Step 2: VERIFY (evidence required)
Run the project's verification command (defined in project CLAUDE.md). If none exists, run the type checker or test suite at minimum. If verification fails, fix and re-verify before proceeding.

**Evidence rules**: Show exact pass/fail counts. No hedging language. Must be fresh (run after latest change). See `anti-rationalization.md` for the full list of verification red flags.

### Step 2b: VISUAL VERIFY (frontend/UI changes only)
If the plan involved UI changes:
1. **Desktop with preview**: If `.claude/launch.json` exists and preview tools are available, use `preview_*` tools (screenshot, snapshot, inspect, console_logs). Desktop auto-verifies after each edit, so confirm results here.
2. **CLI with Chrome**: If Chrome is connected (`/chrome`), suggest `/verify-ui` to visually check changes in a browser.
3. **Neither available**: Skip visual verification, note in the execution checklist.

Check for console errors, visual regressions, broken layouts.
Skip if: backend-only changes, no web target.

### Step 2c: SIMPLIFY
Run `/simplify` on all changed files. This step is **MANDATORY** for every implementation — it runs autonomously as part of the loop, not as a user-chosen action.

1. `/simplify` detects mode automatically (lightweight for small changes, full for larger ones)
2. Auto-fix changes are applied directly (structural simplifications, idiomatic patterns)
3. Suggestions that alter public API shape are shown to the user for quick approval
4. If changes were made, re-run verification to confirm nothing broke
5. If verification fails after a simplification, revert that specific change and continue

This step is the bridge between "code that works" and "code that's clean." It runs before review so the reviewer sees the best version of the code.

### Step 2d: SECURITY GATE (conditional)
Triggers when changes touch ANY of: `auth/`, `security/`, RLS policies, migration files, API route handlers, user input handling, `package.json`/`requirements.txt` (dependency changes).

1. Spawn `security-reviewer` agent on changed files
2. If CRITICAL findings: must fix before proceeding to Step 3
3. If HIGH findings: warn user, allow acknowledgement to proceed
4. If MEDIUM/LOW only: log findings, continue

Skip if: changes are purely UI/styling, documentation, or test files with no auth/data concerns.

### Step 2e: TEST COVERAGE NUDGE (conditional)
After implementation, check if new public functions, exported APIs, or route handlers were added without corresponding tests.

1. Compare `git diff --diff-filter=A --name-only` (newly added files only) against test file patterns (`*.test.*`, `*.spec.*`, `__tests__/`)
2. If new source files were added but no test files: suggest spawning `test-writer` agent
3. If new exports were added to existing files but no test changes: note it as a suggestion (not a blocker)

This is advisory, not mandatory. The user can decline. Skip if:
- Changes are purely config, docs, or styling
- The project has no existing test infrastructure
- The user explicitly stated no tests needed

### Step 2f: ACCEPTANCE GATE (mandatory for plan-mode tasks)
A separate evaluator checks the implementation against the plan's acceptance criteria. This is **structural, not optional** — it runs before review, not as a user-chosen action. Inspired by the GAN-pattern finding that agents reliably praise their own work; separation of generator and evaluator is the fix.

1. **Spawn an evaluator agent** (model: `opus` for 3+ file changes, `sonnet` otherwise) with:
   - The plan's acceptance criteria (from the spec section — these are the single source of truth)
   - `git diff` of all changes
   - Access to the running application (if applicable — use browser tools or curl)
2. **The evaluator checks each acceptance criterion** individually:
   - PASS: criterion is met, with evidence (e.g., "tested endpoint X, returned expected shape Y")
   - FAIL: criterion is not met, with specific finding (e.g., "delete button exists but clicking it returns 500 — error handler missing in route.ts:45")
3. **Hard gate with iteration limit**: If ANY criterion fails, fix the failed items and re-run the gate. **Maximum 2 rounds**. After 2 failed rounds, surface all remaining findings to the user and let them decide whether to override or continue fixing. This prevents infinite ping-pong between implementer and evaluator.
4. **Evaluator must be skeptical**: Prompt it to actively look for gaps, not confirm success. Include: "Your job is to find what's broken, not validate what works. If you find yourself writing 'looks good' — look harder."
5. **Log the evaluator's findings** in the session log.
6. **Note on locked interfaces**: Locked interfaces from the plan (exact types/signatures) are enforced by implementer discipline during Step 1, not by this gate. The gate checks behavioral acceptance criteria. If you changed a locked interface during implementation, note the deviation in the session log with justification.

**After review**: If Step 3 (review) or Step 4 (fix) produces significant changes, the gate results may be stale. Re-run the gate if review fixes touched functionality covered by acceptance criteria. Minor fixes (formatting, naming, style) don't require a re-run.

**Skip when**:
- Quick fix (no plan, no spec, no acceptance criteria to check against)
- Pure library code where Step 2 (test suite) already covers all acceptance criteria
- User explicitly opts out

When skipped, mark as `[~]` in the execution checklist with justification.

### Step 3: REVIEW
In Desktop: suggest the built-in diff view + **Review code** button for inline feedback. In CLI: suggest `/review` for uncommitted changes. For complex work (3+ files, architectural changes, security-sensitive code), suggest `/grill` instead. For automated fix iteration (critic finds issues, you fix, critic re-audits), suggest `/qa`.

### Step 4: FIX
Address issues found in review. Prioritize: critical > major > minor. Don't fix style nits during this step — those go to `/techdebt`.

### Step 5: RE-VERIFY
Run verification again after fixes. If it fails, loop back to Step 4.

### Mid-Implementation Replan

If implementation reveals the plan is fundamentally wrong (not just a minor fix):

1. **Stop implementation**. Don't continue on a broken plan.
2. **Preserve current plan**: Rename to `{plan-file}_v1.md` on disk.
3. **Assess severity**:
   - **Minor adjustment** (data shape wrong, missed edge case): Revise Phase 3 blueprint, re-run Phase 4 devil's advocate, re-propose.
   - **Major rethink** (wrong approach entirely): Restart from Phase 1 (Structured Thinking) with the new information.
4. **Carry forward**: Reference what was learned from v1 in the new plan. Don't re-discover the same dead ends.
5. **Session log**: Append a "Replan" entry explaining what went wrong and why.
6. **WIP commit**: If partial work is salvageable, commit with `WIP:` prefix before replanning.

### Step 6: SATISFACTION CHECK & NEXT ACTIONS
Handled by `session-lifecycle.md` Phase 3. In summary:

1. Present what was implemented + verification results.
2. Present the **Execution Checklist** (below).
3. Ask: **"Are you satisfied with the changes?"**
4. Offer an action menu via AskUserQuestion (multiSelect: true) with relevant options:
   `/review`, `/grill`, `/qa`, `/techdebt`, Preview, `/test-and-fix`, `/commit`, `/pr`, or "More changes needed".
5. Execute chosen actions. If both `/commit` and `/pr` are selected, run sequentially.

See `session-lifecycle.md` Phase 3 for the full action menu table and decision logic.

**MANDATORY**: The **Execution Checklist** must be shown before asking for satisfaction:

```
### Execution Checklist
- [x/~/ ] Feature branch or worktree created (or quick fix on main — justified)
- [x/~/ ] Verification passed (command: `...`)
- [x/~/ ] `/simplify` run on changes (auto-fix applied, suggestions resolved)
- [x/~/ ] Acceptance gate passed (evaluator checked criteria, or N/A — quick fix / <3 criteria)
- [x/~/ ] `/review` run on changes
- [x/~/ ] `/grill` run (if 3+ files or architectural/security changes)
- [x/~/ ] All review findings addressed
- [x/~/ ] `/verify-ui` or Preview run (if frontend/UI changes)
- [x/~/ ] `/commit` suggested or completed
- [x/~/ ] `/techdebt` suggested (if multi-file plan)
- [x/~/ ] `/update-tracker` suggested (if 3+ files or 50+ lines)
- [x/~/ ] Security gate passed (or N/A — no auth/data/dependency changes)
- [x/~/ ] [LEARN] entries created for corrections discovered during implementation
- [x/~/ ] Session log updated (if plan-mode task)
- [x/~/ ] TODO.md updated on main (Done entry after merge)
```

Legend: `[x]` = done, `[~]` = not applicable / skipped with justification, `[ ]` = not done.

If any box is `[ ]` without justification, go back and complete it before asking for satisfaction.

## Agent Sequences (Optional)

For complex workflows, the orchestrator can invoke agents in a deliberate sequence during Step 1 (IMPLEMENT). This is optional — most tasks don't need it. Use agent sequences when the plan explicitly calls for specialized analysis at specific points.

### Predefined Sequences

| Workflow | Sequence | Notes |
|----------|----------|-------|
| **Feature** | architect thinking (in plan mode) → implement → code-reviewer + security-reviewer (parallel) → test-writer | Architect runs during planning, not execution |
| **Bugfix** | debugger → implement fix → code-reviewer → test-writer | Debugger finds root cause before any code changes |
| **Refactor** | code-reviewer (pre-state) → implement → code-reviewer (post-state) → simplify | Pre/post review catches regressions |
| **Security audit** | security-reviewer → code-reviewer → implement fixes → security-reviewer (re-audit) | Two-pass security review brackets the fixes |

### When to Use Sequences

- The plan blueprint explicitly names agents to invoke at specific steps
- The task spans multiple domains (frontend + backend + security)
- Multiple agents need to contribute findings before implementation begins

### When NOT to Use Sequences

- Simple feature implementation (just implement and verify)
- The plan doesn't mention specialized analysis
- Single-domain changes with straightforward verification

### Handoff Documents

When agents run in sequence, each passes a handoff document to the next. This prevents context loss between agents.

```markdown
## Handoff: {from-agent} → {to-agent}

### Key Discoveries
- [What was found that the next agent needs to know]

### Decisions Made
- [Choices already locked in — don't re-litigate]

### Open Questions
- [Unresolved items the next agent should address]

### Files Modified
- [Paths changed so far]

### Verification Results
- [What passed, what failed, what wasn't tested]

### Recommended Next Steps
- [What the next agent should focus on]
```

Include the handoff document in the agent's prompt when spawning it. The receiving agent should read it first before starting its own work.

### Parallel Agent Execution

Agents that don't depend on each other's output can run in parallel:
- code-reviewer + security-reviewer (different concerns, same files)
- test-writer for module A + test-writer for module B (different files)

Use the Agent tool's parallel invocation (multiple tool calls in one message) for these. Synthesize findings in the main session before proceeding.

---

## Important Notes
- This protocol uses your existing slash commands — it doesn't replace them
- Verification pass/fail is the quality gate (no numeric scoring)
- If stuck at any step, surface the blocker to the user instead of spinning
- For multi-session work, update the session log at each step transition
- After `/pr`: In Desktop, suggest enabling **auto-fix** (Claude fixes failing CI checks) and **auto-merge** (squash merge when checks pass) from the CI status bar. In CLI, suggest monitoring CI manually or using `/fix-ci` if checks fail.
