#!/bin/bash
# Stop hook: remind about open PR/MR on current branch.
# Silent no-op if not in a git repo, on main/master, or no open PR.

INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)

[ -z "$CWD" ] && exit 0
cd "$CWD" 2>/dev/null || exit 0

# Only check if in a git repo and not on main/master
BRANCH=$(git branch --show-current 2>/dev/null)
[ -z "$BRANCH" ] && exit 0
[ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] && exit 0

REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
[ -z "$REMOTE_URL" ] && exit 0

# GitHub
if echo "$REMOTE_URL" | grep -q "github.com"; then
  PR_STATE=$(gh pr view --json state --jq '.state' 2>/dev/null)
  if [ "$PR_STATE" = "OPEN" ]; then
    PR_URL=$(gh pr view --json url --jq '.url' 2>/dev/null)
    echo "Open PR on branch '$BRANCH': $PR_URL"
    echo "If merged, switch to main and pull before next session."
  fi
# GitLab
elif echo "$REMOTE_URL" | grep -q "gitlab"; then
  MR_STATE=$(glab mr view --output json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('state',''))" 2>/dev/null)
  if [ "$MR_STATE" = "opened" ]; then
    MR_URL=$(glab mr view --output json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('web_url',''))" 2>/dev/null)
    echo "Open MR on branch '$BRANCH': $MR_URL"
    echo "If merged, switch to main and pull before next session."
  fi
fi

exit 0
