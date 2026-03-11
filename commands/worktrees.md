---
description: List and manage git worktrees for this project. Use for cleanup, browsing archived session context, or freeing disk space.
---

List and manage git worktrees for this project.

1. Run `git worktree list` to show all worktrees
2. For each worktree (excluding the main working tree):
   a. **Branch name**: extract from worktree list output
   b. **Last commit**: `git -C <path> log -1 --format="%cr — %s"`
   c. **Merged status**: check `git branch --merged main | grep <branch>`
   d. **Size**: `du -sh <path> --exclude=node_modules 2>/dev/null` (code only)
   e. **node_modules size**: `du -sh <path>/node_modules 2>/dev/null` (if exists)
   f. **Has session logs**: check for `<path>/.claude/session-logs/`
   g. **Has plans**: check for `<path>/.claude/plans/`
3. Present in a table:

   | Path | Branch | Last Activity | Merged? | Code Size | node_modules |
   |------|--------|--------------|---------|-----------|-------------|

4. Flag candidates for action:
   - MERGED + older than 14 days → "Safe to prune"
   - NOT merged + older than 30 days → "Potentially stale"
   - Has node_modules → show size, offer cleanup
5. Offer actions via AskUserQuestion (multiSelect: true):
   - Prune merged worktrees (`git worktree remove <path>`)
   - Clean node_modules from archived worktrees (`rm -rf <path>/node_modules`)
   - Browse plans/session-logs from a specific worktree
   - Keep all (do nothing)

**Never delete a worktree without explicit user confirmation.**
