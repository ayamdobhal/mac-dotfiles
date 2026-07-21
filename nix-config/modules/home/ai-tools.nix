{ ... }:
let
  # Claude/Codex rewrite these files at runtime, so on switch home-manager
  # finds "existing file in the way" and stalls on stale *.backup clobbers
  # (backupFileExtension = "backup"). force = true overwrites instead of
  # backing up — the repo copy is always the source of truth.
  link = source: { inherit source; force = true; };
in {
  home.file = {
    ".codex/memories/user_preferences.md" =
      link ../../../codex/memories/user_preferences.md;
    ".codex/rules/default.rules" = link ../../../codex/rules/default.rules;

    ".codex/skills/branch-management-preferences" =
      link ../../../codex/skills/branch-management-preferences;
    ".codex/skills/commit-preferences" =
      link ../../../codex/skills/commit-preferences;
    ".codex/skills/pr-publishing-preferences" =
      link ../../../codex/skills/pr-publishing-preferences;

    ".claude/CLAUDE.md" = link ../../../claude/CLAUDE.md;
    ".claude/settings.json" = link ../../../claude/settings.json;
    ".claude/plugins/config.json" = link ../../../claude/plugins/config.json;
    ".claude/plugins/installed_plugins.json" =
      link ../../../claude/plugins/installed_plugins.json;
    ".claude/plugins/known_marketplaces.json" =
      link ../../../claude/plugins/known_marketplaces.json;
  };
}
