---
description: Start an autonomous iteration loop. Default mode runs tests and fixes failures. Use --mode to run feature implementation, refactoring, or migration loops instead. Max 10 iterations with configurable quality gates.
---

Start an autonomous iteration loop. Supports multiple modes beyond test-fix.

## Current Loop State
```bash
$(cat /tmp/ralph-loop-state.json 2>/dev/null || echo '{"active": false, "message": "No active loop"}')
```

## Recent Changes
```bash
$(git diff --name-only HEAD 2>/dev/null | head -10 || echo "No changes detected")
```

---

## Mode Selection

Parse `$ARGUMENTS` for mode and quality flags:

| Flag | Values | Default |
|------|--------|---------|
| `--mode` | `test` \| `feature` \| `refactor` \| `migrate` | `test` |
| `--quality` | `strict` \| `fast` | `strict` |
| `--max` | integer (1-20) | `10` |

Examples:
- `/ralph-loop` — default test-fix loop
- `/ralph-loop --mode feature` — feature implementation loop
- `/ralph-loop --mode refactor --quality fast` — quick refactor loop
- `/ralph-loop --mode migrate --max 15` — migration with higher limit

If no `--mode` flag, fall back to test mode (original behavior).

---

## Mode: test (default)

The original Ralph Wiggum test iteration loop:

1. Detect project type and test command
2. Run tests
3. On **failure**: analyze errors, attempt fixes, continue to next iteration
4. On **success**: output completion promise and exit loop

### Step 1: Detect Project Type

Determine the test command based on changed files and project structure:

| Indicator | Project Type | Test Command |
|-----------|-------------|--------------|
| `pytest.ini`, `conftest.py`, `tests/` with `.py` | Python pytest | `TESTING=true python -m pytest tests/ -v --tb=short --maxfail=3` |
| `mobile/`, expo in `package.json` | React Native/Expo | `cd mobile && npm test` |
| `src/`, `__tests__/`, Next.js | Next.js/React | `npm test` |
| `Cargo.toml` | Rust | `cargo test` |
| Other | Generic | Ask user for test command |

If multiple indicators match, ask user which scope to test. If `$ARGUMENTS` contains a bare command (no `--mode` flag), use it as the test command directly.

### Step 2: Initialize Loop State

Create `/tmp/ralph-loop-state.json`:
```json
{
  "active": true,
  "mode": "test",
  "iteration": 1,
  "max_iterations": 10,
  "quality": "strict",
  "test_command": "<detected or provided command>",
  "started_at": "<ISO timestamp>",
  "status": "running",
  "failures": []
}
```

### Step 3-5: Iterate

- Run tests → on failure: analyze, fix, re-run → on success: output completion promise

---

## Mode: feature

Autonomous feature implementation loop. Requires an approved plan (from plan mode) with numbered steps.

### How It Works

1. **Read the plan**: Load the current plan from `.claude/plans/`. If no plan exists, abort with: "No plan found. Enter plan mode first."
2. **Identify steps**: Extract numbered implementation steps from the blueprint.
3. **Per step**:
   a. Implement the step
   b. Run verification (quality gate — see below)
   c. If verification fails: fix and re-verify (max 3 inner attempts)
   d. If verification passes: mark step complete, move to next
4. **All steps done**: output completion promise

### Quality Gates

| `--quality` | What runs between steps |
|-------------|------------------------|
| `strict` | Full verification: build + types + lint + tests |
| `fast` | Build + type check only |

### State

```json
{
  "active": true,
  "mode": "feature",
  "iteration": 1,
  "max_iterations": 10,
  "quality": "strict",
  "plan_file": "<path to plan>",
  "current_step": 1,
  "total_steps": 5,
  "completed_steps": [],
  "started_at": "<ISO timestamp>",
  "status": "running"
}
```

---

## Mode: refactor

Autonomous refactoring loop. Takes a refactoring target description in `$ARGUMENTS`.

### How It Works

1. **Identify targets**: Scan for the refactoring pattern (e.g., "extract shared validation logic", "convert callbacks to async/await").
2. **Per target**:
   a. Apply the refactoring
   b. Run verification (quality gate)
   c. If verification fails: revert that specific change, skip target, note in state
   d. If verification passes: mark target complete, move to next
3. **All targets done** (or max iterations reached): output completion promise with summary

### Quality Gates

Same as feature mode. `strict` runs full pipeline, `fast` runs build + types only.

### Graceful Termination

Stop the loop when:
- All identified targets are refactored
- 3 consecutive targets fail verification (pattern may not be applicable)
- Max iterations reached

---

## Mode: migrate

Autonomous file-by-file migration loop. For transforming files from one pattern to another (e.g., CJS → ESM, class components → hooks, API v1 → v2).

### How It Works

1. **Identify files**: Find all files matching the migration pattern (via glob or grep).
2. **Per file**:
   a. Transform the file
   b. Run verification (quality gate)
   c. If verification fails: revert, skip file, note in state
   d. If verification passes: mark file complete, move to next
3. **All files done**: output completion promise with migration summary

### State

```json
{
  "active": true,
  "mode": "migrate",
  "iteration": 1,
  "max_iterations": 15,
  "quality": "strict",
  "pattern": "<migration description>",
  "total_files": 12,
  "completed_files": [],
  "skipped_files": [],
  "started_at": "<ISO timestamp>",
  "status": "running"
}
```

---

## Critical Rules (All Modes)

- **MUST output completion promise** when done: `RALPH_LOOP_COMPLETE: <summary>`
- **Max iterations** enforced (default 10, configurable via `--max`)
- **Focus on changed files first** — fix failures related to recent changes before other issues
- **Distinguish test bugs from code bugs** — if the test itself is wrong, fix the test
- **Revert on failure** (refactor/migrate modes) — don't leave broken code
- **Use `/cancel-ralph`** to abort the loop manually
- **Checkpoint before starting** — for feature/refactor/migrate modes, note the starting commit hash in state so the user can revert everything if needed

### Hook Integration (Optional)

For full autonomous iteration (where Claude can't exit until the loop completes), add a project-level Stop hook that:
1. Reads `/tmp/ralph-loop-state.json`
2. If `active: true` and no `RALPH_LOOP_COMPLETE` in output: blocks exit, re-injects task
3. If `active: false` or completion promise found: allows normal exit

Without a hook, the command still works — it just won't block you from stopping early.

---

Begin by parsing mode/quality flags from arguments, initializing loop state, and starting the first iteration.
