#!/bin/bash
# PostToolUse hook: suggest running verification after multiple file edits.
# Also tracks verification timestamp for warn-commit.sh gate.
# Runs async — never blocks Claude.
COUNTER_FILE="/tmp/claude-edit-count-${PPID}"
VERIFY_FILE="${HOME}/.claude/.last-verify"
[ ! -f "$COUNTER_FILE" ] && echo "0" > "$COUNTER_FILE"

COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

if [ "$COUNT" -eq 5 ]; then
  echo "5 files modified this session — consider running the project's verification command."
  echo "0" > "$COUNTER_FILE"
fi

# Track verification runs: if the tool output mentions test/build/verify success,
# touch the timestamp file. This is a heuristic — checks if the Bash command
# looks like a verification command (test, build, tsc, pytest, etc.)
INPUT=$(cat 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if echo "$COMMAND" | grep -qiE '(npm test|npm run test|npx tsc|pytest|cargo test|npm run build|make test|go test|swift test)'; then
  date +%s > "$VERIFY_FILE"
fi
