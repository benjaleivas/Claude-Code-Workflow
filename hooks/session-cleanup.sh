#!/bin/bash
# SessionEnd hook: clean up temp files from ralph-loop and other session artifacts.
rm -f /tmp/ralph-loop-state.json 2>/dev/null
rm -f /tmp/claude-log-reminder-*.count 2>/dev/null
rm -f /tmp/claude-edit-count-* 2>/dev/null
