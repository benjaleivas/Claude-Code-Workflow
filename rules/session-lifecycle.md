# Session Lifecycle

The full lifecycle of a Claude Code session, from start to cleanup. This governs every session across all projects.

## Phase 0: Session Start — Setup Checklist

On the **first message** of every new session, present an interactive setup checklist. Use AskUserQuestion for key decisions.

### Conductor Workspace Detection

If `$CONDUCTOR_WORKSPACE_PATH` is set, the session is inside a Conductor workspace:
- **Skip worktree suggestion** — the workspace IS the isolation
- **Skip branch creation** — Conductor already created the branch
- **Branch rename**: Use `git branch -m benjaleivas/{description}` (not `git worktree move`)
- **Proceed directly to plan mode** after checking MEMORY.md
- All slash commands, agents, hooks, and skills work as-is in Conductor workspaces

### For Non-Trivial Tasks (features, bugs, multi-file changes)

1. **Project**: Confirm the working directory. If no project CLAUDE.md exists, offer to scaffold one (see `new-project-setup.md`).
2. **MEMORY.md**: Check for relevant [LEARN] entries and mention them.
3. **Task classification**: Classify the request:
   - Feature / non-trivial → full lifecycle (worktree + plan mode)
   - Bug / error → debugger pattern, worktree if multi-file
   - Exploration / prototype → suggest `/explore`
   - Risky / data-heavy → suggest `/container`
4. **Worktree**: Ask the user to create a worktree (Desktop: worktree button; CLI: `claude --worktree` or `/worktree`). This isolates the work and auto-creates a feature branch. In Conductor, skip this — the workspace already provides isolation.
   - If the user declines, fall back to manual branch creation in the orchestrator Step 0.
5. **Architecture complexity**: Ask whether this task is architecturally ambiguous (multiple viable approaches, high cost of choosing wrong). Use AskUserQuestion:
   - **Standard planning** (default) — single agent with explicit divergence. `<brainstorm>` must list 2-3 named approaches before committing to one.
   - **Competing architectures** — 2-3 parallel Plan agents, each building a full blueprint for a different architectural direction. User picks the winner or synthesizes. See `plan-mode-workflow.md` Phase 2.5.
6. **Scope gear** (standard planning only — skip if competing architectures): Ask the user's intent via AskUserQuestion. See `plan-mode-workflow.md` Phase 1 for full definitions.
   - **HOLD SCOPE** (default) — maximize rigor within the given scope
   - **EXPANSION** — find the 10-star product, push ambition, map the dream state
   - **REDUCTION** — absolute minimum that delivers user value, cut everything else
7. **Plan mode**: Enter plan mode for the task. Follow `plan-mode-workflow.md`.

Present this as an interactive flow, prompting the user at each decision point (folder, worktree yes/no, branch name if manual).

### For Quick Fixes (single-file, <20 lines)

Show an abbreviated 3-step checklist:
```
Quick fix workflow:
 [ ] 1. Fix the issue
 [ ] 2. Verify (tests/type check)
 [ ] 3. /simplify (lightweight — auto)
 [ ] 4. /commit
```
No worktree, no plan mode, no branching. Proceed directly to implementation.

### Quick Fix Guardrail
After classifying as quick fix, verify BOTH conditions are true:
1. **Single file**: The change touches exactly one file (not "mostly one file" or "one file plus a test")
2. **Under 20 lines**: The total diff will be under 20 lines of actual code changes

If either condition is uncertain, escalate to non-trivial workflow. When in doubt, plan.

Additionally: if a "quick fix" grows beyond 20 lines or touches a second file during implementation, STOP and suggest switching to plan mode. Present via AskUserQuestion:
- "This grew beyond quick fix scope (N files, ~N lines). Switch to plan mode?"

### Skip Entirely When:
- Follow-up messages in an ongoing session
- Continuation sessions (context summaries indicate prior work)
- User's message is a slash command

---

## Phase 1: Planning

Follows `plan-mode-workflow.md` (5 phases: Thinking → Questions → Blueprint → Devil's Advocate → Propose).

Plan includes branch name, spec, and verification strategy. Plan is saved to disk.

---

## Phase 2: Execution

Follows `orchestrator-protocol.md` (Steps 0-5: Branch → Implement → Verify → Simplify → Review → Fix → Re-verify).

If a worktree was created in Phase 0, the orchestrator Step 0 detects it and skips branch creation.

---

## Phase 3: Satisfaction Check & Next Actions

**Replaces the old orchestrator Step 6.** After implementation and verification are complete:

1. Present a summary of what was implemented + verification results.
2. Present the **Execution Checklist** (see `orchestrator-protocol.md`).
3. Ask the user: **"Are you satisfied with the changes?"**
4. Based on their answer, offer the relevant next actions via AskUserQuestion:

### Action Menu (use AskUserQuestion, multiSelect: true)

| Action | When to suggest | Description |
|--------|----------------|-------------|
| `/review` | Always | Quick pre-commit review |
| `/grill` | 3+ files or security/arch changes | Adversarial pre-push gate |
| `/qa` | Complex changes | Automated critic-fixer loop |
| `/techdebt` | Multi-file plans | Cleanup pass |
| Preview | Web/UI changes | See changes in browser |
| `/test-and-fix` | When tests exist | Run test suite, fix failures |
| `/commit` | When ready | Stage and commit changes |
| `/pr` | When ready to ship | Push branch + create PR |
| More changes | User not satisfied | Loop back to implementation |

Present only the relevant subset based on the work done. Always include `/commit` and `/pr`.

5. Execute the user's chosen actions in order.
6. If `/commit` and `/pr` are both selected, run them sequentially (commit first, then PR).

---

## Phase 4: Ship

After the user chooses to ship:

1. `/commit` — if not already done in Phase 3.
2. `/grill` — if not already run and the work is 3+ files or architectural.
3. `/pr` — push branch + create PR.
4. **CI monitoring**:
   - Desktop: suggest enabling **auto-fix** and **auto-merge** from the CI status bar.
   - CLI: suggest monitoring CI manually or using `/fix-ci` if checks fail.
5. Wait for PR to merge (user confirms or Claude detects via `gh pr status`).
6. **Production verification** (web changes only): After merge, spawn `vercel-specialist` to confirm the new deployment is `● Ready` and the affected pages render correctly. Use `vercel ls` and `WebFetch` on the production URL.

---

## Phase 5: Cleanup

After the PR is merged and closed:

1. **Detect merge**: Check `gh pr status` or user confirms the PR is merged.
2. **Switch to main**: `git checkout main && git pull --ff-only`
3. **Delete merged branch**: `git branch -d {branch-name}` (local only — remote is deleted by GitHub on merge).
4. **Keep worktree**: Worktrees persist as read-only session archives (plans, logs, code). Only prune manually or via `/techdebt` when no longer needed.
5. **End-of-session tasks**:
   - Suggest `/update-tracker` if significant work (3+ files or 50+ lines).
   - Suggest `/techdebt` for a final sweep.
   - Update session log (if plan-mode task).
   - If this session involved user corrections ("no, that's wrong"), verify [LEARN] entries were created. If any missed, create them now before closing.
   - Update `TODO.md` on main: add completed task to Done (`- [x] type(scope): Description — PR #N`), add any newly discovered tasks to Next Up. If the task wasn't previously in Active (because TODO.md is not edited on feature branches), add it directly to Done.
6. **Close**: Tell the user: "Branch cleaned up. Start a new session for your next task." If a worktree was used, add: "Worktree preserved at `{path}` for future reference."

---

## Lifecycle Diagram

```
Session Start
  │
  ├─ Quick fix? → fix → verify → /simplify → /commit → done
  │
  └─ Non-trivial:
       │
       ├─ Create worktree (isolate work)
       ├─ Enter plan mode (with scope gear: HOLD / EXPANSION / REDUCTION)
       │    ├─ Standard: think → questions → blueprint → devil's advocate → propose
       │    └─ Competing: think → questions → 2-3 parallel plans → pick/synthesize → devil's advocate → propose
       │
       ├─ Plan approved → orchestrator activates
       │    └─ branch → implement → verify → /simplify → review → fix → re-verify
       │
       ├─ Satisfaction check
       │    ├─ Not satisfied → loop back to implementation
       │    └─ Satisfied → choose actions (/review, /grill, /commit, /pr...)
       │
       ├─ Ship: /commit → /grill → /pr → CI
       │
       └─ Cleanup: merge → delete branch → new session (worktree preserved)
```
