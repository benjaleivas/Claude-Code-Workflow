# Context Management

Guidelines for managing context window usage and surviving auto-compaction.

## MCP Context Budget

MCP tool schemas consume significant context (~50-100K tokens across all servers). Rules add ~10K tokens. The biggest context savings come from MCP consolidation (disabling unused servers in app settings), not from trimming rules.

| Tier | MCPs | Guidance |
|------|------|----------|
| Core (always on) | Supabase, GitHub (gh CLI), Context7, Vercel | Necessary for daily work |
| On-demand | Figma, AWS, Kubernetes, Gmail, Calendar, Chrome | High schema cost — disable when not needed |
| Minimal footprint | Slack, Notion, PDF, Scheduled Tasks, MCP Registry | Low cost, keep enabled |

Reference: `~/.claude/docs/mcp-audit.md` for the full catalog.

## Context Hygiene

1. **Use subagents for exploration**: Offload research, file discovery, and broad searches to subagents. Their context is isolated — findings come back as a summary, not raw output.
2. **Targeted reads**: Read specific line ranges instead of entire files when you know what you need. Use `offset` and `limit` parameters.
3. **Extract, don't dump**: When analyzing large outputs (test results, build logs, API responses), extract the relevant parts and discard the rest. Don't paste 500 lines of logs into conversation.
4. **Scope file edits**: Use `Edit` (sends only the diff) instead of `Write` (sends entire file) for modifications to existing files.
5. **Prune conversation**: If a research tangent produced nothing useful, acknowledge it and move on. Don't rehash dead ends.

## Pre-Compaction Checklist

Context compaction is automatic — Claude Code triggers it when approaching limits. The `pre-compact.sh` hook fires before compaction. To prepare:

1. **Persist decisions**: If you've made design decisions during this session, write them to the session log before they're compressed away.
2. **Save plan state**: If mid-implementation, note which plan steps are done and which remain.
3. **Commit partial work**: If code changes are in a working state, suggest a WIP commit to preserve progress.

## Recovery After Compaction

After compaction, conversation history is summarized. To recover context:

1. **Session log**: Read `{project}/.claude/session-logs/` for reasoning history
2. **Plan artifact**: Read `{project}/.claude/plans/` for the implementation blueprint
3. **Git state**: Check `git status`, `git log --oneline -5`, and `git diff` to see current state
4. **MEMORY.md**: Re-check for relevant [LEARN] entries

The summary from compaction provides a high-level overview, but specific implementation details may be lost. Disk artifacts are the source of truth.
