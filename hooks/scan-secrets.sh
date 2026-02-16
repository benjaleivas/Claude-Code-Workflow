#!/bin/bash
# Scan for accidentally introduced API keys or secrets after file edits.
# Runs async — never blocks Claude.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

# Skip test files, fixtures, and lock files
echo "$FILE_PATH" | grep -qE '(test|fixture|mock|__tests__|\.test\.|\.spec\.|\.lock|lock\.)' && exit 0

# Scan for common secret patterns
SECRETS=$(grep -nE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|xox[bsrap]-[0-9a-zA-Z\-]+|eyJ[a-zA-Z0-9_-]{20,}\.eyJ|glpat-[a-zA-Z0-9\-]{20,})' "$FILE_PATH" 2>/dev/null)

if [ -n "$SECRETS" ]; then
  echo "WARNING: Possible secrets detected in $FILE_PATH"
  echo "$SECRETS" | head -5
  echo "Use environment variables instead of hardcoded secrets."
fi
