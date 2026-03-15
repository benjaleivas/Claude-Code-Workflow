---
name: retro
description: Engineering retrospective from git history. Velocity metrics, session patterns, hotspot analysis, fix ratio, streak tracking. Saves JSON snapshots for trend comparison.
---

# Engineering Retrospective

Analyze the project's git history to generate a data-driven retrospective. Produces velocity metrics, coding patterns, and quality signals.

## Arguments

- No argument: analyze the last 7 days (default)
- `--days N`: analyze the last N days
- `compare`: compare current window against the previous same-length window (e.g., this week vs last week)

## Data Collection

Run these git commands to gather raw data:

```bash
# Commits in window
git log --since="$DAYS days ago" --format="%H|%ae|%an|%aI|%s" --no-merges

# Insertions/deletions per commit
git log --since="$DAYS days ago" --format="%H" --no-merges | while read h; do git diff --shortstat "$h^" "$h" 2>/dev/null; done

# File hotspots (most changed files)
git log --since="$DAYS days ago" --format="" --name-only --no-merges | sort | uniq -c | sort -rn | head -15

# Commit type breakdown (from conventional commit prefixes or keywords)
git log --since="$DAYS days ago" --format="%s" --no-merges
```

## Metrics to Compute

### Velocity
| Metric | How |
|--------|-----|
| Commits to main | Count of merged commits |
| Contributors | Unique `author_email` |
| PRs merged | `gh pr list --state merged --search "merged:>YYYY-MM-DD"` |
| Lines: +insertions / -deletions / net | Sum from shortstat |
| Test LOC ratio | Lines in test files vs total |

### Work Patterns
| Metric | How |
|--------|-----|
| Active days | Unique dates with commits |
| Work sessions | Group commits by 45-min gaps: deep (50+ min), medium (20-50), micro (<20) |
| Peak hours | Histogram of commit hours (local timezone) |
| Focus score | % of commits touching the single most-changed top-level directory |

### Quality Signals
| Metric | How |
|--------|-----|
| Fix ratio | Commits containing "fix" / total commits. High ratio (>30%) signals review gaps |
| Hotspot files | Top 5 most-changed files. Frequent churn = potential design issue |
| Commit streak | Consecutive days with commits (current + longest) |
| AI collaboration | % of commits with `Co-Authored-By` trailer |

### Per-Contributor Breakdown (if multiple authors)
For each contributor:
- Commit count, LOC (insert/delete/net)
- Top 3 directories/files touched
- Commit type breakdown (feat/fix/refactor/test)
- Biggest shipped item (longest commit message or most LOC)

Frame growth observations as investment advice, not criticism. Anchor all praise in actual commits.

## Output Format

```markdown
## Retro: [Project Name] — [Date Range]

### Velocity
[Table of metrics]

### Work Patterns
[Session analysis, peak hours, focus score]

### Quality Signals
[Fix ratio, hotspots, streaks, AI collab %]

### Contributors
[Per-person breakdown if multiple authors]

### Trends (if compare mode)
[Delta arrows for key metrics: ↑ improving, ↓ declining, → stable]

### Observations
[2-3 sentences: what went well, what to watch, one actionable suggestion]

### Tweetable Summary
[One sentence capturing the week/window]
```

## Snapshot Persistence

After generating the retro, save a JSON snapshot:

```bash
mkdir -p {project}/.claude/session-logs/retros
```

Filename: `{project}/.claude/session-logs/retros/YYYY-MM-DD.json`

The JSON should include all computed metrics (velocity, patterns, quality, per-contributor) so future `compare` runs can compute deltas without re-running git commands.

Before saving, check for the most recent prior snapshot. If found, compute deltas for: test ratio, session count, fix ratio, commit volume, focus score. Display trends with directional arrows (↑↓→).

## Rules

- All timestamps in the user's local timezone
- Don't editorialize beyond the data — let metrics speak
- If fix ratio exceeds 30%, flag it explicitly as a quality signal
- If a single file appears in hotspots 3+ retros in a row, flag it as a potential design issue
- The retro is read-only — never modify code or commit based on retro findings
