#!/bin/bash
# Pre-compaction hook: saves a context snapshot to the active session log.
# Fails silently if no session log exists (quick fix, no plan mode).

set -e

# Read the working directory from stdin (JSON context)
INPUT=$(cat)
WORK_DIR=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

if [ -z "$WORK_DIR" ]; then
  exit 0
fi

SESSION_LOG_DIR="$WORK_DIR/.claude/session-logs"

# Find the most recent session log (if any)
if [ ! -d "$SESSION_LOG_DIR" ]; then
  exit 0
fi

LATEST_LOG=$(ls -t "$SESSION_LOG_DIR"/*.md 2>/dev/null | head -1)

if [ -z "$LATEST_LOG" ]; then
  exit 0
fi

# Append a compression marker
echo "" >> "$LATEST_LOG"
echo "---" >> "$LATEST_LOG"
echo "**Context compressed at $(date '+%Y-%m-%d %H:%M')**. Review entries above if context was lost." >> "$LATEST_LOG"
echo "---" >> "$LATEST_LOG"
