#!/bin/bash
# working.sh — Yellow tab: Claude is actively processing your request.
set -euo pipefail
[[ ! -w /dev/tty ]] && exit 0

# Yellow (R=230, G=190, B=0)
printf '\033]6;1;bg;red;brightness;230\a' > /dev/tty
printf '\033]6;1;bg;green;brightness;190\a' > /dev/tty
printf '\033]6;1;bg;blue;brightness;0\a' > /dev/tty
exit 0
