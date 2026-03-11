#!/bin/bash
# attention.sh — Red tab: Claude is blocked, waiting for user input or permission.
set -euo pipefail
[[ ! -w /dev/tty ]] && exit 0

# Red (R=220, G=40, B=40)
printf '\033]6;1;bg;red;brightness;220\a' > /dev/tty
printf '\033]6;1;bg;green;brightness;40\a' > /dev/tty
printf '\033]6;1;bg;blue;brightness;40\a' > /dev/tty
exit 0
