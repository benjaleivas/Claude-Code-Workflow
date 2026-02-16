Run the test suite and fix any failures.

1. Determine the test command for this project:
   - Check package.json for test scripts (npm test, bun test, etc.)
   - Check for pytest, jest, vitest, or other test runners
   - If $ARGUMENTS is provided, use it as the test command
2. Run the full test suite
3. If all tests pass: report success and stop
4. If tests fail:
   a. Read each failure carefully
   b. Determine whether the bug is in the test or the implementation
   c. Fix ONE failure at a time
   d. Re-run the full suite after each fix to confirm it worked and didn't break other tests
   e. Repeat until all tests pass
5. If a test appears flaky (passes sometimes, fails sometimes), flag it but don't delete it

Fix one at a time. Verify before moving to the next. Never skip a failing test by deleting it.
