---
description: Enter exploration mode with relaxed quality gates. For prototyping, data experiments, and quick proofs-of-concept.
---

# Exploration Mode

Exploration mode lets you prototype, experiment, and explore ideas without the overhead of the full orchestrator pipeline. No `/review`, no `/grill`, no session logs. Just build.

## Starting Exploration

When invoked with a description (e.g., `/explore duckdb-query-optimizer`):

1. Create the exploration directory if it doesn't exist:
   ```
   explorations/YYYY-MM-DD_<description>/
   ```
2. Announce: **"Exploration mode active."** Quality gates are relaxed:
   - No `/review` or `/grill` required
   - No session logs
   - No orchestrator protocol
   - Verification is optional (but still recommended for sanity)
3. All new files go inside the exploration directory
4. Existing project files can be READ but not modified during exploration

## During Exploration

- Work fast. Don't worry about code quality, naming, or structure.
- Install packages, try APIs, run scripts — whatever moves the experiment forward.
- If something works, note it. If it doesn't, move on.
- Keep a mental (or written) note of what's worth keeping.

## Ending Exploration (`/explore done`)

When the user runs `/explore done`:

1. Summarize what was built/discovered in the exploration
2. List the files created in `explorations/`
3. Ask: **"Promote any of this to the project? If yes, which files?"**
4. If promoting:
   - Move the selected files to their proper project location
   - Run the full orchestrator pipeline on the promoted code (verify → review → commit)
   - The promoted code gets the same quality treatment as any other change
5. If not promoting:
   - Leave everything in `explorations/` for reference
   - Suggest adding `explorations/` to `.gitignore` if not already there

## Rules

- Exploration directories are NOT committed by default. Add `explorations/` to `.gitignore`.
- Exploration mode doesn't give permission to modify existing project files without gates. It only relaxes gates for NEW files within the exploration directory.
- If the user wants to modify existing project code during exploration, exit exploration mode first.
- Container pairing: `/explore` works especially well inside a `/container` — experiment with full OS isolation.
