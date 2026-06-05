---
name: branch-management-preferences
description: Use whenever the user asks Codex to create, switch to, prepare, or name a local git branch, including requests like "make a branch", "branch this off", "start a branch", or "checkout a new branch". This skill covers branch workflow and naming only; use commit-preferences for local commits and pr-publishing-preferences for pushing or opening pull requests.
---

# Branch Management Preferences

Apply these preferences when creating or switching git branches.

- Inspect `git status` and the current branch before creating or switching branches.
- Do not include `codex` in branch names.
- Prefer concise kebab-case branch names with a useful prefix such as `fix/`, `feat/`, `chore/`, or `refactor/`.
- Choose the prefix from the work being done, not from the user's wording.
- If a requested branch already exists, switch to it instead of failing or creating a near-duplicate.
- Do not discard, reset, stash, or overwrite unrelated worktree changes unless the user explicitly asks.
- If branch creation happens inside a submodule or nested repo, say which repo the branch was created in.
- Do not push the branch unless the user explicitly asks to push or open a PR.
