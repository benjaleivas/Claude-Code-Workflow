#!/bin/bash
# attention.sh — iTerm2 visual attention indicator
# Called by Claude Code hooks when waiting for user input.
# Sets tab color to amber/orange and badge to "⏰ pending".
# Uses /dev/tty for iTerm2 escape sequences (hooks lack a direct terminal).

set -euo pipefail

# Guard: only run inside iTerm2
if [[ "${TERM_PROGRAM:-}" != "iTerm.app" ]]; then
  exit 0
fi

# Guard: /dev/tty must be writable
if [[ ! -w /dev/tty ]]; then
  exit 0
fi

# --- Set tab color: amber/orange (R=255, G=165, B=0) ---
printf '\033]6;1;bg;red;brightness;255\a' > /dev/tty
printf '\033]6;1;bg;green;brightness;165\a' > /dev/tty
printf '\033]6;1;bg;blue;brightness;0\a' > /dev/tty

# --- Set badge: "⏰ pending" ---
# iTerm2 badges require base64-encoded text
badge_text="⏰ pending"
if command -v base64 &>/dev/null; then
  badge_b64=$(printf '%s' "$badge_text" | base64)
  printf '\033]1337;SetBadgeFormat=%s\a' "$badge_b64" > /dev/tty
fi

# --- Optional: macOS notification (fire-and-forget) ---
osascript -e 'display notification "Claude Code needs your attention" with title "⏰ Claude Code"' 2>/dev/null &

exit 0
