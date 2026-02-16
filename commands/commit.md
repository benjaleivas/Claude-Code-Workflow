Commit the current changes with a clear message.

1. Run `git status` to see all changes (never use -uall flag)
2. Run `git diff` to review staged and unstaged changes
3. Run `git log --oneline -5` to see recent commit message style
4. Stage the appropriate files with `git add` — prefer specific files over `git add -A` to avoid accidentally staging secrets or binaries
5. Write a commit message that:
   - Starts with a verb (add, fix, update, remove, refactor)
   - Focuses on WHY not WHAT
   - Follows the repo's existing style from step 3
   - Is 1-2 sentences max
6. Create the commit using a HEREDOC for the message
7. Run `git status` to verify the commit succeeded

Do NOT push to remote — use `/pr` for that.
Do NOT amend previous commits.
Do NOT use `--no-verify`.
If there are no changes to commit, say so and stop.
