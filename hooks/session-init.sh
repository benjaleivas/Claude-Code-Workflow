#!/bin/bash
# SessionStart hook: detect project type and inject context.
INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)

[ -z "$CWD" ] && exit 0
cd "$CWD" 2>/dev/null || exit 0

CONTEXT=""

# Detect project type
[ -f "app.json" ] && grep -q "expo" "app.json" 2>/dev/null && CONTEXT="${CONTEXT}Expo project detected.\n"
[ -f "supabase/config.toml" ] && CONTEXT="${CONTEXT}Supabase project detected.\n"
{ [ -f "deno.json" ] || [ -f "deno.jsonc" ]; } && CONTEXT="${CONTEXT}Deno project detected.\n"
[ -f "pyproject.toml" ] || [ -f "setup.py" ] && CONTEXT="${CONTEXT}Python project detected.\n"
[ -f "Package.swift" ] || [ -f "*.xcodeproj" ] 2>/dev/null && CONTEXT="${CONTEXT}Swift/Xcode project detected.\n"

# Check for Claude scaffolding
[ -f ".claude/MEMORY.md" ] && CONTEXT="${CONTEXT}Project MEMORY.md exists — check for [LEARN] entries before implementing.\n"
[ -d ".claude/session-logs" ] && CONTEXT="${CONTEXT}Session logs directory exists.\n"
[ -d ".claude/agents" ] && CONTEXT="${CONTEXT}Project-level agents available.\n"

# Output context (if any detected)
if [ -n "$CONTEXT" ]; then
  printf "%b" "$CONTEXT"
fi
