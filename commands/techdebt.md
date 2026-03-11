---
description: End-of-session codebase cleanup. Use at the end of a session or after multi-file changes to find and remove duplicated code, dead code, unused imports, and resolved TODOs.
---

End-of-session codebase cleanup. Find and kill duplicated and dead code.

**Relationship to /simplify**: `/simplify` runs on the CURRENT changeset (files you just modified) as part of the orchestrator loop. `/techdebt` runs on the ENTIRE codebase looking for cross-file patterns, stale branches, dead code, and historical duplication that `/simplify` can't see. Always assume `/simplify` has already run on recent changes.

1. Scan the codebase for:
   - **Duplicated code**: 3+ similar lines appearing in multiple places that could be extracted
   - **Dead code**: unused exports, functions, variables, and types
   - **Unused imports**: imports that are no longer referenced
   - **Resolvable TODOs**: TODO/FIXME/HACK comments where the fix is now obvious or the issue is resolved
2. Present findings grouped by severity:
   - **Fix now** (safe, no behavior change): dead code, unused imports, resolved TODOs
   - **Refactor** (needs care): duplicated blocks that should be extracted
   - **Discuss** (needs decision): TODOs that require product/design input
3. Fix "fix now" items one at a time, running typecheck or tests after each fix to verify nothing breaks
4. Ask before touching "refactor" items — show the proposed extraction
5. Leave "discuss" items as-is, just report them
6. Commit the cleanup work separately from feature commits
7. Check for stale branches: `git branch --merged main | grep -v main`
   - If merged branches exist, list them and offer to delete: `git branch -d <branch>`
   - Skip if on a feature branch that hasn't been merged yet
8. **TODO.md Audit**: Check for stale Active entries:
   - For each `- [ ]` entry in Active, check if the branch still exists: `git branch --list {branch-name}`
   - If the branch doesn't exist and no open PR references it (`gh pr list --head {branch-name}`): flag as stale
   - Present stale entries to user: "These TODO items have no active branch or PR. Remove them?"

9. **Worktree Audit**: Run `git worktree list`
   - For each non-main worktree: check if branch merged (`git branch --merged main | grep <branch>`)
   - If merged AND last commit >14 days ago: suggest pruning
   - If NOT merged but last commit >30 days: flag as potentially stale
   - Report total disk usage of worktrees
   - Offer to clean node_modules from archived worktrees (saves disk without losing code/logs)

Focus on the files touched in this session first, then scan broadly if time permits.
