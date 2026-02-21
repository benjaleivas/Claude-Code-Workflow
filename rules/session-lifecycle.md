# Session Lifecycle

The full lifecycle of a Claude Code session, from start to cleanup. This governs every session across all projects.

## Phase 0: Session Start — Setup Checklist

On the **first message** of every new session, present an interactive setup checklist. Use AskUserQuestion for key decisions.

### For Non-Trivial Tasks (features, bugs, multi-file changes)

1. **Project**: Confirm the working directory. If no project CLAUDE.md exists, offer to scaffold one (see `new-project-setup.md`).
2. **MEMORY.md**: Check for relevant [LEARN] entries and mention them.
3. **Task classification**: Classify the request:
   - Feature / non-trivial → full lifecycle (worktree + plan mode)
   - Bug / error → debugger pattern, worktree if multi-file
   - Exploration / prototype → suggest `/explore`
   - Risky / data-heavy → suggest `/container`
4. **Worktree**: Ask the user to create a worktree (Desktop: worktree button; CLI: `claude --worktree` or `/worktree`). This isolates the work and auto-creates a feature branch.
   - If the user declines, fall back to manual branch creation in the orchestrator Step 0.
5. **Plan mode**: Enter plan mode for the task. Follow `plan-mode-workflow.md`.

Present this as an interactive flow, prompting the user at each decision point (folder, worktree yes/no, branch name if manual).

### For Quick Fixes (single-file, <20 lines)

Show an abbreviated 3-step checklist:
```
Quick fix workflow:
 [ ] 1. Fix the issue
 [ ] 2. Verify (tests/type check)
 [ ] 3. /commit
```
No worktree, no plan mode, no branching. Proceed directly to implementation.

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

Follows `orchestrator-protocol.md` (Steps 0-5: Branch → Implement → Verify → Review → Fix → Re-verify).

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
| `/simplify` | Complex new code | Reduce unnecessary complexity |
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

---

## Phase 5: Cleanup

After the PR is merged and closed:

1. **Detect merge**: Check `gh pr status` or user confirms the PR is merged.
2. **Switch to main**: `git checkout main && git pull --ff-only`
3. **Delete merged branch**: `git branch -d {branch-name}` (local only — remote is deleted by GitHub on merge).
4. **Delete worktree** (if used): The worktree prompt on session exit handles this, or manually with `git worktree remove {path}`.
5. **End-of-session tasks**:
   - Suggest `/update-tracker` if significant work (3+ files or 50+ lines).
   - Suggest `/techdebt` for a final sweep.
   - Update session log (if plan-mode task).
6. **Close**: Tell the user: "Branch and worktree cleaned up. Start a new session for your next task."

---

## Lifecycle Diagram

```
Session Start
  │
  ├─ Quick fix? → fix → verify → /commit → done
  │
  └─ Non-trivial:
       │
       ├─ Create worktree (isolate work)
       ├─ Enter plan mode
       │    └─ think → questions → blueprint → devil's advocate → propose
       │
       ├─ Plan approved → orchestrator activates
       │    └─ branch → implement → verify → review → fix → re-verify
       │
       ├─ Satisfaction check
       │    ├─ Not satisfied → loop back to implementation
       │    └─ Satisfied → choose actions (/review, /grill, /commit, /pr...)
       │
       ├─ Ship: /commit → /grill → /pr → CI
       │
       └─ Cleanup: merge → delete branch → delete worktree → new session
```
