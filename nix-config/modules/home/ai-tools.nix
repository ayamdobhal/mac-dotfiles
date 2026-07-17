{ ... }: {
  home.file = {
    ".codex/memories/user_preferences.md".source =
      ../../../codex/memories/user_preferences.md;
    ".codex/rules/default.rules".source = ../../../codex/rules/default.rules;

    ".codex/skills/branch-management-preferences".source =
      ../../../codex/skills/branch-management-preferences;
    ".codex/skills/commit-preferences".source =
      ../../../codex/skills/commit-preferences;
    ".codex/skills/pr-publishing-preferences".source =
      ../../../codex/skills/pr-publishing-preferences;

    ".claude/CLAUDE.md".source = ../../../claude/CLAUDE.md;
    ".claude/settings.json".source = ../../../claude/settings.json;
    ".claude/statusline-command.sh" = {
      source = ../../../claude/statusline-command.sh;
      executable = true;
    };
    ".claude/plugins/blocklist.json".source =
      ../../../claude/plugins/blocklist.json;
    ".claude/plugins/config.json".source = ../../../claude/plugins/config.json;
    ".claude/plugins/installed_plugins.json".source =
      ../../../claude/plugins/installed_plugins.json;
    ".claude/plugins/known_marketplaces.json".source =
      ../../../claude/plugins/known_marketplaces.json;
  };
}
