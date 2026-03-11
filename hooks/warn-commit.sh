#!/bin/bash
# PreToolUse hook: warn if committing without recent verification.
# WARNING only — does not block. Set CLAUDE_SKIP_GATE=1 to suppress.
[ "$CLAUDE_SKIP_GATE" = "1" ] && exit 0

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check git commit commands
echo "$COMMAND" | grep -q 'git commit' || exit 0

# Session state file (shared with other hooks)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
STATE_FILE="${PROJECT_ROOT}/.claude/.session-state"

# Check for recent verification (within last 30 minutes)
LAST_VERIFY=$(grep '^last_verify=' "$STATE_FILE" 2>/dev/null | cut -d= -f2)

if [ -z "$LAST_VERIFY" ]; then
  echo "Warning: No verification has been run this session. Consider running the project's verification command before committing."
  exit 0
fi

# Convert ISO timestamp to epoch for comparison
if date -j -f "%Y-%m-%dT%H:%M:%S" "$LAST_VERIFY" +%s >/dev/null 2>&1; then
  LAST_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$LAST_VERIFY" +%s)
else
  LAST_EPOCH=$(date -d "$LAST_VERIFY" +%s 2>/dev/null || echo "0")
fi

NOW=$(date +%s)
AGE=$(( NOW - LAST_EPOCH ))

if [ "$AGE" -gt 1800 ]; then
  echo "Warning: Last verification was $(( AGE / 60 )) minutes ago. Consider re-running verification before committing."
fi
