#!/bin/bash
# UserPromptSubmit hook: warn if user accidentally pastes API keys in prompt.
# Exit code 2 = block the prompt.
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null)

[ -z "$PROMPT" ] && exit 0

# Check for common secret patterns
if echo "$PROMPT" | grep -qE '(sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|eyJ[a-zA-Z0-9_-]{20,}\.eyJ|glpat-[a-zA-Z0-9\-]{20,})'; then
  echo "Warning: Your prompt appears to contain an API key or token. Consider using a placeholder instead." >&2
  exit 2
fi
