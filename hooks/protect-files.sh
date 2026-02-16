#!/bin/bash
# Block accidental edits to sensitive files and lock files.
# Exit code 2 = block the operation.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[ -z "$FILE_PATH" ] && exit 0

# Block direct .env and .key edits (allow .example, .template, .test, .sample)
if echo "$FILE_PATH" | grep -qE '\.(env|key)(\.|$)' && ! echo "$FILE_PATH" | grep -qE '\.(example|template|test|sample)'; then
  echo "Blocked: Direct modification of sensitive file. Use environment management tools instead." >&2
  exit 2
fi

# Block secrets, credentials, and API config files (allow test/mock/fixture files)
if echo "$FILE_PATH" | grep -qiE '(secrets|credentials|api[._-]?config)' && ! echo "$FILE_PATH" | grep -qE '(test|mock|fixture)'; then
  echo "Blocked: Sensitive configuration file. Use environment variables instead." >&2
  exit 2
fi

# Block lock file edits
if echo "$FILE_PATH" | grep -qE '(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Podfile\.lock|bun\.lockb)$'; then
  echo "Blocked: Lock files should not be edited directly. Run the package manager instead." >&2
  exit 2
fi
