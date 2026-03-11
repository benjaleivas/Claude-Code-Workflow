#!/bin/bash
# done.sh — iTerm2 "task complete" indicator
# Called by Claude Code hooks when Claude finishes (Stop event).
# Sets tab color to green and badge to "✅ done".
# The green state persists until the next user prompt clears it.

set -euo pipefail

# Guard: only run inside iTerm2
if [[ "${TERM_PROGRAM:-}" != "iTerm.app" ]]; then
  exit 0
fi

# Guard: /dev/tty must be writable
if [[ ! -w /dev/tty ]]; then
  exit 0
fi

# --- Set tab color: green (R=0, G=200, B=80) ---
printf '\033]6;1;bg;red;brightness;0\a' > /dev/tty
printf '\033]6;1;bg;green;brightness;200\a' > /dev/tty
printf '\033]6;1;bg;blue;brightness;80\a' > /dev/tty

# --- Set badge: "✅ done" ---
badge_text="✅ done"
if command -v base64 &>/dev/null; then
  badge_b64=$(printf '%s' "$badge_text" | base64)
  printf '\033]1337;SetBadgeFormat=%s\a' "$badge_b64" > /dev/tty
fi

# --- Optional: macOS notification (fire-and-forget) ---
osascript -e 'display notification "Claude Code has finished" with title "✅ Claude Code"' 2>/dev/null &

exit 0
