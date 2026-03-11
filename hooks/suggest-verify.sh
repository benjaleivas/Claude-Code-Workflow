#!/bin/bash
# PostToolUse hook: suggest running verification after multiple file edits.
# Also tracks verification timestamp for warn-commit.sh gate.
# Runs async — never blocks Claude.

# Session state file (shared with other hooks)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
STATE_FILE="${PROJECT_ROOT}/.claude/.session-state"

# Ensure .claude directory exists
mkdir -p "$(dirname "$STATE_FILE")"

# Read current edit count from session state
COUNT=$(grep '^edit_count=' "$STATE_FILE" 2>/dev/null | cut -d= -f2)
COUNT=${COUNT:-0}
COUNT=$((COUNT + 1))

# Update edit_count in session state
if grep -q '^edit_count=' "$STATE_FILE" 2>/dev/null; then
  sed -i '' "s/^edit_count=.*/edit_count=$COUNT/" "$STATE_FILE"
else
  echo "edit_count=$COUNT" >> "$STATE_FILE"
fi

if [ "$COUNT" -eq 5 ]; then
  echo "5 files modified this session — consider running the project's verification command."
  # Reset counter
  sed -i '' "s/^edit_count=.*/edit_count=0/" "$STATE_FILE"
fi

# Track verification runs: if the tool output mentions test/build/verify success,
# touch the timestamp file. This is a heuristic — checks if the Bash command
# looks like a verification command (test, build, tsc, pytest, etc.)
INPUT=$(cat 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if echo "$COMMAND" | grep -qiE '(npm test|npm run test|npx tsc|pytest|cargo test|npm run build|make test|go test|swift test)'; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S)
  if grep -q '^last_verify=' "$STATE_FILE" 2>/dev/null; then
    sed -i '' "s/^last_verify=.*/last_verify=$TIMESTAMP/" "$STATE_FILE"
  else
    echo "last_verify=$TIMESTAMP" >> "$STATE_FILE"
  fi
fi
