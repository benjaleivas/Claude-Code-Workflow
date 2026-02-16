Update the work tracker with this session's work.

**MANDATORY**: Run after completing any approved plan (successful or not).

## Session Context

### Git Status
```bash
$(git status --short 2>/dev/null | head -20 || echo "Not a git repo")
```

### Changed Files
```bash
$(git diff --name-only HEAD 2>/dev/null | head -25 || echo "No changes")
```

### Lines Changed
```bash
$(git diff --stat HEAD 2>/dev/null | tail -3 || echo "Unknown")
```

### Recent Commits (Last 4 Hours)
```bash
$(git log --oneline --since="4 hours ago" 2>/dev/null | head -10 || echo "No recent commits")
```

---

## Instructions

### Step 1: Determine Significance

**Significant (LOG IT):**
- New features implemented
- Major bug fixes
- Architectural changes
- Database migrations
- Hook/agent/command changes
- Integration work

**Not Significant (SKIP):**
- Typo fixes
- Minor formatting
- Small config tweaks
- Documentation-only edits (unless substantial)

**Threshold**: 3+ files changed OR 50+ lines changed.

If not significant, inform the user and skip.

### Step 2: Gather Session Details

1. **Focus**: What was the main goal? (e.g., "Implement dark mode")
2. **Work Items**: What was accomplished?
   - Type: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
   - Scope: `web`, `mobile`, `backend`, `claude`, `supabase`, etc.
   - Description: brief summary
3. **Verification**: What commands verified the work? (tests, typecheck, manual)
4. **Learnings**: Key insights or gotchas discovered?

### Step 3: Log the Session

**If project has a helper script** (`.claude/hooks/work_tracker.py`):
```bash
python3 .claude/hooks/work_tracker.py add_session \
  "<focus description>" \
  "<type>:<scope>:<description>" \
  --notes="<learnings>"
```

**If no helper script** (manual update):
Append to the project's `docs/TO-DOS.md` (or create it):

```markdown
### YYYY-MM-DD HH:MM — [Focus Description]
- type(scope): Description of work item
- type(scope): Description of work item
- Verified: [commands run]
- Learnings: [key insights]
```

New entries go at the TOP of the session log section (newest first).

### Step 4: Confirm to User

After updating, report:
- What was logged
- File location
- Summary stats if available

---

## Subcommands

If $ARGUMENTS is provided, interpret as subcommand:

- `$ARGUMENTS = "stats"` — Show session count and recent activity
- `$ARGUMENTS = "add-pending <description>"` — Add a pending task to backlog
- `$ARGUMENTS = "validate"` — Check tracking file structure
