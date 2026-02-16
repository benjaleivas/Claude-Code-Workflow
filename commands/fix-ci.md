Fix failing CI. Don't micromanage — just diagnose and fix.

## Provider Detection
```bash
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "none")
```

Determine the CI platform:
1. If `$REMOTE_URL` contains `github.com` → **GitHub** (use `gh` CLI)
2. If `$REMOTE_URL` contains `gitlab` → **GitLab** (use `glab` CLI)
3. If a `.gitlab-ci.yml` exists in the project root → **GitLab**
4. If none of the above → ask the user which platform they use

If the required CLI (`gh` or `glab`) is not installed, inform the user:
- GitHub: "Install with `brew install gh` and run `gh auth login`"
- GitLab: "Install with `brew install glab` and run `glab auth login`"

## Recent CI Runs

**GitHub:**
```bash
$(gh run list --limit 5 2>/dev/null || echo "gh CLI not available or not in a git repo with GitHub remote")
```

**GitLab:**
```bash
$(glab ci list --per-page 5 2>/dev/null || echo "glab CLI not available or not in a git repo with GitLab remote")
```

---

## Instructions

### 1. Find the failure

**GitHub:**
- If $ARGUMENTS is a run ID or URL: `gh run view $ARGUMENTS --log-failed`
- If no arguments: pick the most recent failed run from the list above and fetch its logs: `gh run view <id> --log-failed`

**GitLab:**
- If $ARGUMENTS is a pipeline/job ID: `glab ci view $ARGUMENTS` then `glab ci trace <job-id>`
- If no arguments: pick the most recent failed pipeline from the list above: `glab ci view <id>`
- To get the full job log: `glab ci trace <job-id>`

### 2. Diagnose
- Read the failed logs carefully
- Determine root cause: code bug? flaky test? env/config issue? dependency problem? CI config error?
- If the logs are truncated:
  - GitHub: `gh run view <id> --log --job=<job-id>`
  - GitLab: `glab ci trace <job-id>`

### 3. Fix locally
- Make targeted fixes to the code (not the CI config, unless CI itself is the problem)
- Run local verification: project's verify command, `/test-and-fix`, or the specific failing test

### 4. Confirm
- Re-run the full local test suite to make sure the fix doesn't break other things
- Suggest `/commit` when done

Don't ask clarifying questions unless the failure is truly ambiguous. Read the logs, find the root cause, fix it.
