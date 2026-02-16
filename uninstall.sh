#!/bin/bash
# Uninstall claude-workflow: replace symlinks with copies.
# After running, ~/.claude/ is standalone again (no dependency on repo).
set -e

CLAUDE_DIR="$HOME/.claude"

echo "=== Claude Workflow Uninstaller ==="
echo ""

for item in CLAUDE.md settings.json agents commands hooks rules container; do
    target="$CLAUDE_DIR/$item"
    if [ -L "$target" ]; then
        # Resolve symlink, copy contents, remove symlink
        real_path="$(readlink "$target")"
        rm "$target"
        cp -r "$real_path" "$target"
        echo "Copied: $item (was symlink → $real_path)"
    else
        echo "Skipped: $item (not a symlink)"
    fi
done

echo ""
echo "=== Uninstall Complete ==="
echo ""
echo "~/.claude/ is now standalone. You can safely move or delete the repo."
