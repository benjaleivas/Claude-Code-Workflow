# [LEARN] Tag System

Persistent corrections that compound across sessions. When a mistake is caught or a correction is made, tag it so it never recurs.

## Format
```
[LEARN:tag] Brief description of what went wrong and the correct approach
```

Examples:
- `[LEARN:stripe] Checkout sessions don't include line_items by default — must use expand parameter`
- `[LEARN:supabase] RLS policies don't apply to service role — always test with anon key`
- `[LEARN:expo] expo-router v4 uses file-based routing — no manual route registration`
- `[LEARN:rn] FlatList onEndReached fires on mount if data is short — guard with a flag`

## Where They Live
- Written to **project-level** `{project}/.claude/MEMORY.md` under the "Corrections Log" section
- NEVER in the transversal `~/.claude/CLAUDE.md` (keeps it lean)
- Tags are searchable by domain: `[LEARN:rn]`, `[LEARN:supabase]`, `[LEARN:stripe]`, `[LEARN:expo]`

## When to Write
- After any user correction ("no, that's wrong because...")
- After discovering an API behaves differently than expected
- After a debugging session reveals a non-obvious gotcha
- Only for corrections that would recur — not one-off typos

## When to Read
- Before implementing in a domain, check MEMORY.md for relevant [LEARN] entries
- At session start for multi-session projects

## Relationship to Auto Memory
Claude Code also maintains automatic notes at `~/.claude/projects/<project>/memory/MEMORY.md`. Auto memory captures patterns Claude notices on its own. [LEARN] tags capture explicit corrections from the user. Both coexist — auto memory is passive observation, [LEARN] tags are active corrections.

## Maintenance
- Periodic cleanup via `/revise-claude-md`
- Remove entries that are no longer relevant (e.g., after a library upgrade)
