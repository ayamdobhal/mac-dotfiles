{ config, ... }:
{
  # Keybindings are not managed here: skhd reads ~/.config/skhd/skhdrc straight
  # from the dotfiles checkout, so an edit applies with `skhd --reload`.
  services.skhd.enable = true;

  # launchd starts agents with a bare system PATH; the bindings call yabai,
  # scripts in ~/.local/bin and brew-installed tools.
  launchd.agents.skhd.config.EnvironmentVariables.PATH = builtins.concatStringsSep ":" [
    "${config.home.profileDirectory}/bin"
    "${config.home.homeDirectory}/.local/bin"
    "/opt/homebrew/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
}
