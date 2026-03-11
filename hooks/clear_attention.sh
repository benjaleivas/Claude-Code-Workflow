#!/bin/bash
# clear_attention.sh — Default tab: reset to no color. Used on session start.
set -euo pipefail
[[ ! -w /dev/tty ]] && exit 0

printf '\033]6;1;bg;*;default\a' > /dev/tty
exit 0
