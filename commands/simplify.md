Simplify the code that was just written. Act as a code-simplifier.

1. Find recently changed files: `git diff --name-only`
2. Use a subagent to scan each changed file and find:
   - Overly complex conditionals that can be flattened or simplified
   - Abstractions used only once — inline them
   - Verbose patterns that have simpler equivalents in this language/framework
   - Functions doing too many things — split them or simplify the flow
   - Unnecessary defensive code — checks that can never fail given the calling context
   - Premature abstractions — helpers/utilities for one-time operations
3. For each finding: show a clear before/after diff
4. Only apply changes that maintain **identical behavior** — simplification, not modification
5. Run typecheck (and tests if available) after each change to verify nothing broke
6. Do NOT add features, comments, docstrings, or type annotations — only subtract complexity

Less code is almost always better code.
