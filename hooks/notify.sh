#!/bin/bash
# Notification hook: macOS desktop alert when Claude needs user attention.
osascript -e 'display notification "Claude Code needs your attention" with title "Claude Code"' 2>/dev/null || true
