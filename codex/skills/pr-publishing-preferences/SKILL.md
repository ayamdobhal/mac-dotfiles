---
name: pr-publishing-preferences
description: Use whenever the user asks Codex to push a branch for review or create, open, publish, update, or make a GitHub pull request. This skill covers PR publishing behavior only; use branch-management-preferences for branch creation/switching and commit-preferences for local commits.
---

# PR Publishing Preferences

Apply these preferences before pushing or creating a pull request.

- Use conventional commit format for PR titles.
- Do not include `codex` in branch names or PR titles.
- Create pull requests as ready for review by default; only create a draft PR when the user explicitly asks for one.
- Inspect `git status` before pushing or opening the PR.
- If the worktree has unrelated changes, leave them unstaged unless the user explicitly includes them.
- Do not amend or force-push while publishing unless the user explicitly asks for history rewriting.
- The PR description body should only contain a summary section, any reference/related PRs, and any important heads-up notes when required.
- If local commits are required before publishing, also follow `commit-preferences`.
- If a branch must be created before publishing, also follow `branch-management-preferences`.

When this skill conflicts with a generic GitHub publishing workflow, this skill wins.
