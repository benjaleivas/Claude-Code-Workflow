Start an autonomous test iteration loop. Runs tests, fixes failures, repeats until all pass (max 10 iterations).

## Current Loop State
```bash
$(cat /tmp/ralph-loop-state.json 2>/dev/null || echo '{"active": false, "message": "No active loop"}')
```

## Recent Changes
```bash
$(git diff --name-only HEAD 2>/dev/null | head -10 || echo "No changes detected")
```

---

## Ralph Wiggum Iteration Loop

You are entering an **autonomous iteration loop** that will:
1. Detect project type and test command
2. Run tests
3. On **failure**: analyze errors, attempt fixes, continue to next iteration
4. On **success**: output completion promise and exit loop
5. **Safety limit**: max 10 iterations

### Step 1: Detect Project Type

Determine the test command based on changed files and project structure:

| Indicator | Project Type | Test Command |
|-----------|-------------|--------------|
| `pytest.ini`, `conftest.py`, `tests/` with `.py` | Python pytest | `TESTING=true python -m pytest tests/ -v --tb=short --maxfail=3` |
| `mobile/`, expo in `package.json` | React Native/Expo | `cd mobile && npm test` |
| `src/`, `__tests__/`, Next.js | Next.js/React | `npm test` |
| `Cargo.toml` | Rust | `cargo test` |
| Other | Generic | Ask user for test command |

If multiple indicators match, ask user which scope to test. If $ARGUMENTS is provided, use it as the test command directly.

### Step 2: Initialize Loop State

Create `/tmp/ralph-loop-state.json`:
```json
{
  "active": true,
  "iteration": 1,
  "max_iterations": 10,
  "test_command": "<detected or provided command>",
  "started_at": "<ISO timestamp>",
  "status": "running",
  "failures": []
}
```

### Step 3: Run Tests

Execute the detected test command and capture output.

### Step 4: On Test Failure

- Analyze error messages and stack traces
- Make targeted fixes to the failing code (not the tests, unless the tests are wrong)
- Update the iteration count in state file
- Re-run tests
- Continue until pass or max iterations

### Step 5: On Test Success

Output exactly:
```
RALPH_LOOP_COMPLETE: All tests passed for [scope description]
```

This completion promise signals that the loop is done.

---

### Critical Rules

- **MUST output completion promise** when tests pass: `RALPH_LOOP_COMPLETE: <reason>`
- **Max 10 iterations** by default (safety limit)
- **Focus on changed files first** — fix failures related to recent changes before other issues
- **Distinguish test bugs from code bugs** — if the test itself is wrong, fix the test
- **Use `/cancel-ralph`** to abort the loop manually

### Hook Integration (Optional)

For full autonomous iteration (where Claude can't exit until tests pass), add a project-level Stop hook that:
1. Reads `/tmp/ralph-loop-state.json`
2. If `active: true` and no `RALPH_LOOP_COMPLETE` in output: blocks exit, re-injects task
3. If `active: false` or completion promise found: allows normal exit

Without a hook, the command still works — it just won't block you from stopping early.

---

Begin by detecting the project type, initializing loop state, and running the first test iteration.
