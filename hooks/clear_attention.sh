#!/bin/bash
# clear_attention.sh — Clear iTerm2 visual attention indicator
# Called by Claude Code hooks when the user submits a prompt (i.e., they're back).
# Resets tab color to default and clears the badge.

set -euo pipefail

# Guard: only run inside iTerm2
if [[ "${TERM_PROGRAM:-}" != "iTerm.app" ]]; then
  exit 0
fi

# Guard: /dev/tty must be writable
if [[ ! -w /dev/tty ]]; then
  exit 0
fi

# --- Reset tab color to default ---
printf '\033]6;1;bg;*;default\a' > /dev/tty

# --- Clear badge (empty base64 = no badge) ---
printf '\033]1337;SetBadgeFormat=\a' > /dev/tty

exit 0
