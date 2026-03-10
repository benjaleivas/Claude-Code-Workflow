#!/bin/bash
# Worktree Setup Hook (SessionStart)
# Detects if we're in a git worktree that hasn't been fully set up yet.
# If so: installs dependencies and copies .env files from the main repo.

INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)

[ -z "$CWD" ] && exit 0
cd "$CWD" 2>/dev/null || exit 0

# ── Am I in a worktree? ──────────────────────────────────────────
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)

# If they're the same (or git fails), we're not in a worktree — nothing to do
[ -z "$GIT_COMMON" ] || [ -z "$GIT_DIR" ] && exit 0
[ "$GIT_COMMON" = "$GIT_DIR" ] && exit 0

# Resolve the main repo root from the common git dir
MAIN_REPO=$(cd "$GIT_COMMON/.." 2>/dev/null && pwd)
[ -z "$MAIN_REPO" ] || [ ! -d "$MAIN_REPO" ] && exit 0

# Don't re-run if already set up (marker file)
MARKER="$CWD/.claude/.worktree-setup-done"
[ -f "$MARKER" ] && exit 0

ACTIONS=""

# ── Step 1: Install dependencies ─────────────────────────────────
install_deps() {
  # Priority 1: project-level config
  local config="$CWD/.claude/worktree-config.json"
  if [ -f "$config" ]; then
    local cmd
    cmd=$(python3 -c "import sys,json; print(json.load(open('$config')).get('installCommand',''))" 2>/dev/null)
    if [ -n "$cmd" ]; then
      eval "$cmd" >&2 2>&1
      return $?
    fi
  fi

  # Priority 2: auto-detect from lockfile (check worktree first, then main repo)
  for dir in "$CWD" "$MAIN_REPO"; do
    if [ -f "$dir/bun.lockb" ] || [ -f "$dir/bun.lock" ]; then
      bun install >&2 2>&1; return $?
    elif [ -f "$dir/pnpm-lock.yaml" ]; then
      pnpm install >&2 2>&1; return $?
    elif [ -f "$dir/yarn.lock" ]; then
      yarn install >&2 2>&1; return $?
    elif [ -f "$dir/package-lock.json" ]; then
      npm install >&2 2>&1; return $?
    fi
  done

  # Priority 3: fallback — if package.json exists but no lockfile
  if [ -f "$CWD/package.json" ] || [ -f "$MAIN_REPO/package.json" ]; then
    npm install >&2 2>&1; return $?
  fi

  return 1  # No JS project detected
}

if [ -f "$CWD/package.json" ] && [ ! -d "$CWD/node_modules" ]; then
  install_deps
  if [ $? -eq 0 ]; then
    ACTIONS="${ACTIONS}Installed dependencies.\n"
  else
    ACTIONS="${ACTIONS}WARNING: dependency install failed — run manually.\n"
  fi
fi

# ── Step 2: Copy .env files from main repo ───────────────────────
copy_env_files() {
  local copied=0
  # Find all .env* files in the main repo root (not recursive)
  for envfile in "$MAIN_REPO"/.env*; do
    [ ! -f "$envfile" ] && continue
    local basename
    basename=$(basename "$envfile")

    # Skip if already exists in worktree
    [ -f "$CWD/$basename" ] && continue

    cp "$envfile" "$CWD/$basename"
    copied=$((copied + 1))
  done
  echo "$copied"
}

COPIED=$(copy_env_files)
if [ "$COPIED" -gt 0 ]; then
  ACTIONS="${ACTIONS}Copied $COPIED .env file(s) from main repo.\n"
fi

# ── Step 3: Copy .claude/launch.json if it exists ────────────────
if [ -f "$MAIN_REPO/.claude/launch.json" ] && [ ! -f "$CWD/.claude/launch.json" ]; then
  mkdir -p "$CWD/.claude"
  cp "$MAIN_REPO/.claude/launch.json" "$CWD/.claude/launch.json"
  ACTIONS="${ACTIONS}Copied .claude/launch.json for preview server.\n"
fi

# ── Mark as set up ───────────────────────────────────────────────
mkdir -p "$CWD/.claude"
touch "$MARKER"

# ── Report ───────────────────────────────────────────────────────
if [ -n "$ACTIONS" ]; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  printf "Worktree setup complete (branch: %s):\n" "$BRANCH"
  printf "%b" "$ACTIONS"
fi
