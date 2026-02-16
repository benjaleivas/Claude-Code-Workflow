#!/bin/bash
# PostToolUse hook: suggest running verification after multiple file edits.
# Runs async — never blocks Claude.
COUNTER_FILE="/tmp/claude-edit-count-${PPID}"
[ ! -f "$COUNTER_FILE" ] && echo "0" > "$COUNTER_FILE"

COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

if [ "$COUNT" -eq 5 ]; then
  echo "5 files modified this session — consider running the project's verification command."
  echo "0" > "$COUNTER_FILE"
fi
