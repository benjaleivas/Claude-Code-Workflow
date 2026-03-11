---
description: Tag the current HEAD with a semantic version and create a GitHub release. Use when code on main is ready for a versioned release.
---

Tag the current HEAD with a semantic version and create a GitHub release.

1. Check current branch — must be on main/master. If not, warn and stop.
2. Ensure working tree is clean: `git status --porcelain`
3. Get the last tag: `git describe --tags --abbrev=0 2>/dev/null`
   - If no tags exist, mention this is the first release
4. Ask the user for version bump type (major/minor/patch) or a specific version number via AskUserQuestion
5. Generate changelog since last tag: `git log $(git describe --tags --abbrev=0 2>/dev/null)..HEAD --oneline`
   - If no previous tag: `git log --oneline -20`
6. Show the changelog and confirm the version with the user
7. Create annotated tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
8. Push tag: `git push origin vX.Y.Z`
9. Create GitHub release: `gh release create vX.Y.Z --generate-notes --title "vX.Y.Z"`
10. Print the release URL

Do NOT run on feature branches.
Do NOT create tags without user confirmation of the version number.
