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

### Multi-Session GitHub Coordination
When resuming work across sessions:
1. Check open PRs: `gh pr list --author @me --state open`
2. Check PR status/checks: `gh pr checks <number>`
3. Check for review comments: `gh pr view <number> --comments`
4. If reviewer left feedback: address comments, push updates, re-request review

If a session needs context from past work:
- Run `git worktree list` to see all preserved worktrees
- Browse `{worktree}/.claude/session-logs/` and `{worktree}/.claude/plans/` for reasoning and decisions
- Preserved worktrees are reference-only archives — do not reuse them for new work, start a fresh worktree instead

For parallel work on independent tasks:
- **CLI**: Use `claude --worktree` to start a session with automatic worktree isolation
- **Desktop**: Each new session (+ New session) auto-creates an isolated worktree

## Worktree Awareness

Git worktrees are pre-branched — each worktree has its own branch by design. When inside a worktree:
- The orchestrator Step 0 detects it and skips branch creation
- Branch naming still applies (the worktree branch should follow the convention)
- The `/pr` flow works normally from a worktree

### Worktree Setup Checklist

Worktrees share git history but NOT untracked/ignored files. On first use, a worktree needs:
1. **Install dependencies**: `npm install` (or equivalent) — `node_modules/` is gitignored and not shared
2. **Copy environment files**: `.env.local`, `.env`, or similar — these are gitignored and must be copied from the main repo (`cp {main-repo}/.env.local .`)
3. **Verify**: run the project's dev server or type checker to confirm the worktree is functional

Do this BEFORE starting implementation — don't discover it mid-work.

## Worktree Lifecycle

Worktrees persist after sessions end as reference-only archives. They are NOT deleted automatically.
- **Purpose**: future sessions can browse plans, session logs, and code to recover context
- **Pruning**: manual — run `git worktree list`, cross-reference with merged branches, remove stale ones with `git worktree remove {path}`
- **Rule**: never reuse an old worktree for new work — always create a fresh one

### Worktree Archival Strategy
- **Preserved by default**: session logs, plans, and code remain accessible
- **node_modules cleanup**: safe to delete from archived worktrees — recoverable via `npm install`. The `/worktrees` command offers this.
- **Pruning cadence**: `/techdebt` checks for merged-branch worktrees every session
- **On-demand management**: `/worktrees` for listing, browsing, and cleanup
- **Cross-worktree context**: browse `{worktree}/.claude/plans/` and `{worktree}/.claude/session-logs/` to recover reasoning from past work
- **Storage rule**: code and reasoning are cheap to keep. node_modules are expensive and recoverable. Prune dependencies, preserve decisions.
