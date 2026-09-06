{ ... }: {
  # The repository lives at ~/.config, so ghostty/config is a native tracked
  # file. The user's NixOS login shell supplies Zsh without a generated override.
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };
}
