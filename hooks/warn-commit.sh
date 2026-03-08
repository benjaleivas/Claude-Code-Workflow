#!/bin/bash
# PreToolUse hook: warn if committing without recent verification.
# WARNING only — does not block. Set CLAUDE_SKIP_GATE=1 to suppress.
[ "$CLAUDE_SKIP_GATE" = "1" ] && exit 0

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check git commit commands
echo "$COMMAND" | grep -q 'git commit' || exit 0

# Check for recent verification (within last 30 minutes)
VERIFY_FILE="${HOME}/.claude/.last-verify"
if [ ! -f "$VERIFY_FILE" ]; then
  echo "Warning: No verification has been run this session. Consider running the project's verification command before committing."
  exit 0
fi

LAST_VERIFY=$(cat "$VERIFY_FILE" 2>/dev/null)
NOW=$(date +%s)
AGE=$(( NOW - LAST_VERIFY ))

if [ "$AGE" -gt 1800 ]; then
  echo "Warning: Last verification was $(( AGE / 60 )) minutes ago. Consider re-running verification before committing."
fi
