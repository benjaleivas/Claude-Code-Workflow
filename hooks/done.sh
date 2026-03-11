#!/bin/bash
# done.sh — Green tab: Claude finished, your turn.
set -euo pipefail
[[ ! -w /dev/tty ]] && exit 0

# Green (R=0, G=180, B=70)
printf '\033]6;1;bg;red;brightness;0\a' > /dev/tty
printf '\033]6;1;bg;green;brightness;180\a' > /dev/tty
printf '\033]6;1;bg;blue;brightness;70\a' > /dev/tty
exit 0
