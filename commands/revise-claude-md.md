---
name: revise-claude-md
description: Review and maintain CLAUDE.md and MEMORY.md — clean stale entries, find duplicates, identify promotion candidates
---

Review the project's MEMORY.md and CLAUDE.md for maintenance. Follow these steps:

## 1. Load MEMORY.md
Read `{project}/.claude/MEMORY.md` (or project root `MEMORY.md`). If it doesn't exist, report and stop.

## 2. Check for Stale Entries
For each `[LEARN:tag]` entry:
- Does the referenced API, library, or pattern still apply to this project?
- Has a library upgrade made the correction obsolete?
- Is the entry referencing files or functions that no longer exist?

Flag stale entries for removal.

## 3. Check for Duplicates
Identify `[LEARN]` entries that express the same correction in different words. Suggest merging them into a single, clearer entry.

## 4. Identify Promotion Candidates
Look for patterns that:
- Appear in 3+ `[LEARN]` entries across different domains
- Represent general principles rather than project-specific gotchas
- Would benefit ALL projects, not just this one

Suggest promoting these to a transversal rule in `~/.claude/rules/`.

## 5. Check CLAUDE.md Drift
Verify that the project CLAUDE.md:
- References files and directories that actually exist
- Lists commands and patterns that are current
- Has an accurate tech stack description
- Has a working verification command

## 6. Present Findings
Categorize all findings:

- **Stale** (recommend removal): entries no longer relevant
- **Duplicates** (recommend merge): entries that overlap
- **Promote** (recommend moving to transversal): recurring patterns
- **Drift** (recommend update): outdated CLAUDE.md references

Wait for user approval before making any changes. Show the specific edits for each category.
