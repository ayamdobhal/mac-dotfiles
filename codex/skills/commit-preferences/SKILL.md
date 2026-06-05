---
name: commit-preferences
description: Use whenever the user asks Codex to make, create, prepare, amend, or inspect a local git commit, including requests like "commit this", "make a commit", "commit the current change", or "stage and commit". This skill covers local commit behavior only; use branch-management-preferences for branch creation/switching and pr-publishing-preferences for pushing or opening pull requests.
---

# Commit Preferences

Apply these preferences before making local commits.

- Inspect `git status` and the staged diff before committing.
- Stage only files that belong to the user's requested change.
- Leave unrelated worktree changes unstaged unless the user explicitly includes them.
- Use conventional commits for commit messages.
- Include an extended commit message body for non-trivial commits. Keep the subject conventional and concise, then add body paragraphs covering what changed, why it changed, and relevant validation or risk.
- Do not add Codex or the assistant as a commit co-author.
- Prefer creating a new follow-up commit over amending an existing commit, especially once a branch has been pushed or a PR exists.
- Amend or force-push only when the user explicitly asks for history rewriting.
- After committing, report the branch, commit hash, commit subject, and whether the local worktree is clean.
