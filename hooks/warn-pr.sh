#!/bin/bash
# PreToolUse hook: warn if creating PR without running /grill for 3+ file changes.
# WARNING only — does not block. Set CLAUDE_SKIP_GATE=1 to suppress.
[ "$CLAUDE_SKIP_GATE" = "1" ] && exit 0

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check gh pr create commands
echo "$COMMAND" | grep -q 'gh pr create' || exit 0

# Count changed files on this branch vs main
CHANGED_FILES=$(git diff --name-only main...HEAD 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGED_FILES" -ge 3 ]; then
  # Check if /grill has been run (tracked via timestamp file)
  GRILL_FILE="${HOME}/.claude/.last-grill"
  if [ ! -f "$GRILL_FILE" ]; then
    echo "Warning: ${CHANGED_FILES} files changed but /grill hasn't been run. Consider running /grill before creating a PR."
  fi
fi
