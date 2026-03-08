---
description: Review recent git history and MEMORY.md to extract patterns and suggest new [LEARN] entries. Use monthly or after intensive work periods to compound corrections across sessions.
---

# /evolve — Extract Patterns from Recent Work

You are performing a periodic review of recent work to identify patterns worth persisting as [LEARN] entries.

## Step 1: Gather Evidence

Read the following sources (in parallel where possible):

1. **Recent git history** (last 30 days):
   ```
   git log --since="30 days ago" --oneline --no-merges
   ```
   Then read commit messages and diffs for commits that mention "fix", "revert", "oops", "actually", "correct", or "wrong".

2. **Current MEMORY.md**: Read `{project}/.claude/MEMORY.md` to see existing [LEARN] entries and avoid duplicates.

3. **Session logs** (if they exist): Scan `.claude/session-logs/` for entries from the last 30 days. Look for "discovered", "realized", "actually", "turns out" — signals of learned corrections.

4. **Auto memory**: Check `~/.claude/projects/*/memory/MEMORY.md` for relevant patterns already captured.

## Step 2: Identify Candidate Corrections

Look for these signals in the evidence:

| Signal | What It Means |
|--------|---------------|
| Reverted commit | Something was wrong — what was the correction? |
| "Fix" commit after a feature commit | The feature had a bug — was it a recurring pattern? |
| Same file edited 3+ times in a session | Iteration suggests misunderstanding — what was learned? |
| Session log mentions "turns out..." | Explicit correction — should be a [LEARN] entry |
| Multiple commits touching the same API | API behavior was misunderstood initially |

## Step 3: Draft [LEARN] Entries

For each candidate, draft an entry in this format:
```
[LEARN:tag] Brief description of what went wrong and the correct approach
```

Rules:
- **Tag** should be the domain: `ts`, `python`, `swift`, `supabase`, `expo`, `rn`, `git`, `ci`, etc.
- **Brief** = one sentence. If you need two, it's two entries.
- **Correct approach** must be actionable — what to do differently next time.
- **No duplicates** — check existing MEMORY.md entries first.
- **No generic advice** — only things that actually bit the user in this codebase.

## Step 4: Present for Review

Present all candidate entries to the user in a numbered list. For each:
1. The proposed [LEARN] entry
2. The evidence (commit hash, session log excerpt, or file path)
3. Confidence: HIGH (clear correction), MEDIUM (probable pattern), LOW (might be one-off)

Ask the user to approve, edit, or reject each entry.

## Step 5: Write Approved Entries

Append approved entries to `{project}/.claude/MEMORY.md` under the "Corrections Log" section.

If no project MEMORY.md exists, check if this is a cross-project pattern and suggest adding it to the relevant language rule file (`~/.claude/rules/typescript.md`, etc.) instead.

---

## Example Output

```
Candidates from last 30 days:

1. [LEARN:supabase] RPC functions return data wrapped in { data, error } — always destructure both, don't assume success
   Evidence: commit abc1234 "Fix: handle RPC error response" (reverted previous approach)
   Confidence: HIGH

2. [LEARN:ts] Zod .transform() runs after .refine() — if transform depends on refined data, chain order matters
   Evidence: 3 edits to validation.ts in session 2024-03-01
   Confidence: MEDIUM

3. [LEARN:expo] Image.getSize is async and can fail silently on invalid URIs — always wrap in try/catch
   Evidence: session log mentions "turns out Image.getSize throws on data URIs"
   Confidence: HIGH

Approve all? Or select specific entries to keep/edit/reject.
```

---

Begin by gathering evidence from git history and MEMORY.md.
