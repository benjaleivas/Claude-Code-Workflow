Push the current branch and create a pull request (GitHub) or merge request (GitLab).

## Provider Detection
```bash
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "none")
```

Determine the platform:
1. If `$REMOTE_URL` contains `github.com` → **GitHub** (use `gh` CLI)
2. If `$REMOTE_URL` contains `gitlab` → **GitLab** (use `glab` CLI)
3. If a `.gitlab-ci.yml` exists in the project root → **GitLab**
4. If none of the above → ask the user which platform they use

If the required CLI is not installed:
- GitHub: "Install with `brew install gh` and run `gh auth login`"
- GitLab: "Install with `brew install glab` and run `glab auth login`"

---

## Instructions

1. Run `git log --oneline main..HEAD` (try master if main doesn't exist) to see all commits on this branch
2. Run `git diff main...HEAD` to understand the full scope of changes
3. Check if branch has a remote tracking branch: `git rev-parse --abbrev-ref @{u} 2>/dev/null`
4. Push to remote: `git push -u origin $(git branch --show-current)`

### GitHub: Create PR
5. Check for existing PR: `gh pr view 2>/dev/null`
6. If PR exists, print its URL and stop
7. If no PR, create one with `gh pr create`:
   - Title: short, under 70 characters, starts with a verb
   - Body format:
     ```
     ## Summary
     - bullet points of what changed and why

     ## Test plan
     - [ ] how to verify this works
     ```
8. Print the PR URL

### GitLab: Create MR
5. Check for existing MR: `glab mr view 2>/dev/null`
6. If MR exists, print its URL and stop
7. If no MR, create one with `glab mr create`:
   - Title: short, under 70 characters, starts with a verb
   - Description uses the same Summary + Test plan format as GitHub
   - Add `--fill` to auto-populate from commits if appropriate
8. Print the MR URL
9. Mention: if the project has a GitLab CI Claude job configured, `@claude` comments in the MR will trigger automated responses

---

If on main/master, warn and stop — don't create a PR/MR from the default branch.

---

## Post-PR Follow-up

After creating the PR/MR and printing the URL, remember to check on it later in this session.

### When to Check
- After 2-3 more user messages or tasks — not immediately
- When the user seems to be wrapping up, or before suggesting `/techdebt`
- If the user explicitly asks about the PR status

### How to Check

**GitHub:**
```bash
gh pr view --json state,mergedAt,url --jq '{state: .state, merged: .mergedAt, url: .url}'
```

**GitLab:**
```bash
glab mr view --output json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps({'state': d['state'], 'url': d['web_url']}))"
```

### Based on Status
- **MERGED**: Offer to switch to main and pull:
  ```
  "Your PR was merged! Want me to switch to main and pull?"
  ```
  If yes: `git checkout main && git pull`. Then ask before deleting the old branch (`git branch -d <branch>`).

- **OPEN**: Mention once, don't nag:
  ```
  "FYI, your PR at <url> is still open."
  ```

- **CLOSED** (not merged): Ask if that was intentional.

### Constraints
- Only check once per session. Don't repeatedly ask.
- If context was compressed and you've lost track of the PR, skip — the Stop hook will catch it.
