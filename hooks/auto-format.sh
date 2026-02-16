#!/bin/bash
# Auto-format files after Edit/Write. Detects project formatter.
# Runs async — never blocks Claude.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx)
    # Find nearest prettier config, run if available
    DIR=$(dirname "$FILE_PATH")
    while [ "$DIR" != "/" ]; do
      if [ -f "$DIR/.prettierrc" ] || [ -f "$DIR/.prettierrc.json" ] || [ -f "$DIR/.prettierrc.js" ] || [ -f "$DIR/prettier.config.js" ] || [ -f "$DIR/prettier.config.mjs" ]; then
        cd "$DIR" && npx prettier --write "$FILE_PATH" 2>/dev/null
        break
      fi
      # Check package.json for prettier key
      if [ -f "$DIR/package.json" ] && grep -q '"prettier"' "$DIR/package.json" 2>/dev/null; then
        cd "$DIR" && npx prettier --write "$FILE_PATH" 2>/dev/null
        break
      fi
      DIR=$(dirname "$DIR")
    done
    ;;
  *.py)
    command -v black >/dev/null 2>&1 && black "$FILE_PATH" --quiet 2>/dev/null
    ;;
  *.swift)
    command -v swiftformat >/dev/null 2>&1 && swiftformat "$FILE_PATH" --quiet 2>/dev/null
    ;;
esac
