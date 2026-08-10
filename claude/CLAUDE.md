- do not run linter/formatters, i'll do it manually
- do not add test plans in PR descriptions
- always run formatters/linters when asked to commit/push.
- when sending a PR to slack, send the link to the PR only. DO NOT include a message with it.
- only commit when explicitly told to, let me test first
- always use conventional commits and follow the same format for branch names - feat/*, chore/*, etc.
- do not add claude as a co-author or mention claude anywhere in the commit/PR messages.

## Services & logs (MANDATORY, repos under ~/work/invideo)
- Long-running processes start ONLY via `svc up <name>` — never bare dev-server commands, never backgrounded shell calls. A server whose logs aren't in `.logs/` is invisible.
- Registered services: `api` (iv-pro-api, base 4000), `v45` (iv-pro-copilot-v45, base 4100), `web` (iv-pro-web, base 3000). Cross-service ports are wired automatically per task.
- Inspect: `svc ls [--task]` · `svc logs <name>` · `svc stop|restart <name>` · `svc doctor`.
- Ports: base + 10 × task-index; `svc up <name> --main` claims the canonical port — only for the task the human is actively browser-testing.
- Task worktrees: `svc task new <slug> <repo>…` creates `~/work/invideo/wt/<slug>/<repo>` per repo, copies `.env*`, runs `direnv allow`, assigns the port index. `svc tasks` is the fleet view.

