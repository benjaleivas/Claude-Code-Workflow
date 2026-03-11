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

### Step 0b: TRACK
Add the task to `{project}/TODO.md` under the Active section:
- Format: `- [ ] type(scope): Description — branch: {branch-name}`
- Use the type/scope from the plan's branch name and the plan's one-line goal
- If `TODO.md` doesn't exist, create it using the template from `new-project-setup.md`
- Skip if the task is already listed (e.g., continuation session)

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

### Step 2c: SIMPLIFY
Run `/simplify` on all changed files. This step is **MANDATORY** for every implementation — it runs autonomously as part of the loop, not as a user-chosen action.

1. `/simplify` detects mode automatically (lightweight for small changes, full for larger ones)
2. Auto-fix changes are applied directly (structural simplifications, idiomatic patterns)
3. Suggestions that alter public API shape are shown to the user for quick approval
4. If changes were made, re-run verification to confirm nothing broke
5. If verification fails after a simplification, revert that specific change and continue

This step is the bridge between "code that works" and "code that's clean." It runs before review so the reviewer sees the best version of the code.

### Step 3: REVIEW
In Desktop: suggest the built-in diff view + **Review code** button for inline feedback. In CLI: suggest `/review` for uncommitted changes. For complex work (3+ files, architectural changes, security-sensitive code), suggest `/grill` instead. For automated fix iteration (critic finds issues, you fix, critic re-audits), suggest `/qa`.

### Step 4: FIX
Address issues found in review. Prioritize: critical > major > minor. Don't fix style nits during this step — those go to `/techdebt`.

### Step 5: RE-VERIFY
Run verification again after fixes. If it fails, loop back to Step 4.

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
- [x/~/ ] `/review` run on changes
- [x/~/ ] `/grill` run (if 3+ files or architectural/security changes)
- [x/~/ ] All review findings addressed
- [x/~/ ] `/verify-ui` or Preview run (if frontend/UI changes)
- [x/~/ ] `/commit` suggested or completed
- [x/~/ ] `/techdebt` suggested (if multi-file plan)
- [x/~/ ] `/update-tracker` suggested (if 3+ files or 50+ lines)
- [x/~/ ] Session log updated (if plan-mode task)
- [x/~/ ] TODO.md updated (Active on approval, Done on merge)
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
