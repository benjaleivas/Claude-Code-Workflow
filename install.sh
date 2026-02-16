#!/bin/bash
# Install claude-workflow: symlink repo → ~/.claude/
# Run from the repo root. Backs up existing files before overwriting.
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/.backup-$(date +%Y%m%d-%H%M%S)"

echo "=== Claude Workflow Installer ==="
echo ""
echo "Repo:   $REPO_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Backup existing non-symlink files
backup_needed=false
for item in CLAUDE.md settings.json agents commands hooks rules container; do
    target="$CLAUDE_DIR/$item"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup_needed=true
        break
    fi
done

if [ "$backup_needed" = true ]; then
    echo "Backing up existing config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for item in CLAUDE.md settings.json agents commands hooks rules container; do
        target="$CLAUDE_DIR/$item"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            cp -r "$target" "$BACKUP_DIR/"
            echo "  Backed up: $item"
        fi
    done
    echo ""
fi

# Symlink top-level files
for file in CLAUDE.md settings.json; do
    rm -f "$CLAUDE_DIR/$file"
    ln -sf "$REPO_DIR/$file" "$CLAUDE_DIR/$file"
    echo "Linked: $file"
done

# Symlink directories
for dir in agents commands hooks rules container; do
    rm -rf "$CLAUDE_DIR/$dir"
    ln -sf "$REPO_DIR/$dir" "$CLAUDE_DIR/$dir"
    echo "Linked: $dir/"
done

# Ensure hook scripts are executable
chmod +x "$REPO_DIR"/hooks/*.sh
chmod +x "$REPO_DIR"/container/setup.sh

echo ""
echo "=== Install Complete ==="
echo ""
echo "Your ~/.claude/ now points to this repo."
echo "Edit files here, commit, and push — changes are live immediately."
echo ""
echo "To undo: run ./uninstall.sh"
