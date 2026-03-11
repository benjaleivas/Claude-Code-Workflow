# Git Advanced Operations

Advanced git workflows for conflict resolution, recovery, and release management.

## Merge Conflict Resolution Protocol

1. **Detect**: `git diff --name-only --diff-filter=U` lists conflicted files
2. **For each conflicted file**:
   - Read conflict markers, understand both sides
   - Resolve favoring current branch intent
   - `git add <file>` after resolving
3. **Verify**: run type checker / tests after resolving all conflicts
4. **NEVER auto-resolve** conflicts in auth, migration, or config files — present both sides to user
5. **Generated files** (`package-lock.json`, `yarn.lock`): regenerate instead of manual resolve (`npm install`)

## Recovery Procedures

### Commit on Wrong Branch
```bash
git log -1          # save the hash
git reset HEAD~1    # soft reset (keeps changes)
git stash
git checkout correct-branch
git stash pop
# commit on correct branch
```

### Undo Pushed Commit
Use `git revert <hash>` — never force-push unless explicitly asked by the user.

### Detached HEAD
```bash
git branch temp-recovery        # save current work
git checkout main               # return to main
git cherry-pick temp-recovery   # if the work is valuable
git branch -d temp-recovery     # cleanup
```

### Reflog Recovery
```bash
git reflog                      # find lost commits
git cherry-pick <hash>          # recover specific commit
```

### Amend Policy
Only amend when:
- User explicitly requests it
- Commit has NOT been pushed to remote

## Stash Management

- Always name stashes: `git stash push -m "description"`
- Check existing stashes before creating: `git stash list`
- Prefer `git stash pop` over `git stash apply` (auto-cleans)
- `/techdebt` warns if stash list exceeds 5 entries

## Cherry-Pick

**Use case**: hotfix on main that also goes to a feature branch.

```bash
git cherry-pick <hash>
# resolve conflicts if any
# verify with project's test command
```

## Git Bisect + Debugger Integration

When a regression is found and the cause is unclear:

1. `git bisect start`
2. `git bisect bad HEAD`
3. `git bisect good <known-good-commit>`
4. At each step: run the project's verification command
5. When the bad commit is found: hand off to the debugger agent with the commit diff as context
6. `git bisect reset` to return to original HEAD

## Tag & Release Workflow

**Semantic versioning**: `vMAJOR.MINOR.PATCH`

```bash
# Create annotated tag
git tag -a v1.2.3 -m "Release description"

# Push tag
git push origin v1.2.3

# Create GitHub release with auto-generated notes
gh release create v1.2.3 --generate-notes
```

Use the `/release` command for a guided workflow.
