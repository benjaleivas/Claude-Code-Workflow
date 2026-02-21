# Branching Strategy

Solo-developer feature branch workflow. Main + short-lived feature branches only.

## Convention

Branch names follow `{type}/{description}`:
- `feature/short-description` — new functionality or enhancements
- `fix/short-description` — bug fixes
- `chore/short-description` — refactors, config, dependencies, tooling

Description is lowercase kebab-case, 2-4 words. Examples:
- `feature/dark-mode-toggle`
- `fix/auth-token-expiry`
- `chore/upgrade-expo-sdk`

## When to Branch

**Always branch** when:
- The task enters plan mode (any non-trivial work)
- Multi-file changes
- New features, significant bug fixes

**Stay on main** when:
- Quick fixes: single-file, under ~20 lines, no plan mode
- Typo fixes, comment updates, config tweaks
- The user explicitly says to work on main

## Orchestrator Integration (Step 0)

After plan approval, before implementation begins:
1. Check if in a worktree: compare `git rev-parse --git-common-dir` with `git rev-parse --git-dir`. If they differ, you're in a worktree — skip branch creation (worktrees are pre-branched by design).
2. Check current branch with `git branch --show-current`
3. If already on a feature branch that matches this task, continue on it
4. If on main/master:
   a. Ensure working tree is clean (`git status --porcelain`)
   b. Pull latest: `git pull --ff-only` (skip if no remote or offline)
   c. Create and switch: `git checkout -b {type}/{description}`
5. If on a different feature branch (wrong task), warn the user

The branch name is determined during plan Phase 3 (Blueprint) and recorded in the plan artifact.

## Plan Mode Integration

In Phase 3 (Blueprint), include:
```
**Branch**: `feature/description-here`
```

This makes the branch name part of the plan, recoverable across sessions.

## Commit Command Integration

When `/commit` runs on main/master:
- If the change is trivial (1 file, <20 lines): proceed normally
- If the change is non-trivial (2+ files or 20+ lines): warn:
  "Non-trivial changes on main. Consider creating a feature branch first. Proceed anyway?"
- This is a warning, not a blocker. The user can override.

## PR Flow

After work is complete and reviewed:
1. `/commit` all changes on the feature branch
2. `/grill` for pre-push review
3. `/pr` pushes the branch and creates the PR
4. After PR merges: `git checkout main && git pull`, then delete the old branch

## Branch Cleanup

Stale local branches accumulate over time. Two cleanup mechanisms:
- **Post-merge**: The `/pr` post-merge flow offers to delete the current branch immediately
- **Periodic**: `/techdebt` checks for merged branches: `git branch --merged main | grep -v main`. Offers to delete them.

## Multi-Session Work

If a session starts on a feature branch:
- Continue working on the existing branch
- Check the plan artifact in `.claude/plans/` to recover context if needed

If a session starts on main but should be on a feature branch:
- Check for open PRs: `gh pr list --author @me --state open`
- If a relevant branch exists, switch to it
- If not, follow the normal branching flow

For parallel work on independent tasks:
- **CLI**: Use `claude --worktree` to start a session with automatic worktree isolation
- **Desktop**: Each new session (+ New session) auto-creates an isolated worktree

## Worktree Awareness

Git worktrees are pre-branched — each worktree has its own branch by design. When inside a worktree:
- The orchestrator Step 0 detects it and skips branch creation
- Branch naming still applies (the worktree branch should follow the convention)
- The `/pr` flow works normally from a worktree
