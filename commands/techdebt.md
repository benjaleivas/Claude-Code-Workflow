End-of-session codebase cleanup. Find and kill duplicated and dead code.

1. Scan the codebase for:
   - **Duplicated code**: 3+ similar lines appearing in multiple places that could be extracted
   - **Dead code**: unused exports, functions, variables, and types
   - **Unused imports**: imports that are no longer referenced
   - **Resolvable TODOs**: TODO/FIXME/HACK comments where the fix is now obvious or the issue is resolved
2. Present findings grouped by severity:
   - **Fix now** (safe, no behavior change): dead code, unused imports, resolved TODOs
   - **Refactor** (needs care): duplicated blocks that should be extracted
   - **Discuss** (needs decision): TODOs that require product/design input
3. Fix "fix now" items one at a time, running typecheck or tests after each fix to verify nothing breaks
4. Ask before touching "refactor" items — show the proposed extraction
5. Leave "discuss" items as-is, just report them
6. Commit the cleanup work separately from feature commits

Focus on the files touched in this session first, then scan broadly if time permits.
