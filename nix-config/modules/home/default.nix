{ pkgs, ... }: {
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./neovim.nix
    ./dev.nix
    ./ai-tools.nix
    ./obsidian.nix
    ./spicetify.nix
  ];

  home.stateVersion = "25.05";
  home.username = "ayamdobhal";
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/ayamdobhal" else "/home/ayamdobhal";

  # Skip home-manager's man-page generation. It pulls in nixosOptionsDoc which
  # emits a "builtins.derivation … options.json without proper context" warning
  # on every rebuild. We don't read the HM man pages.
  manual.manpages.enable = false;

  # NOTE: nvim/, ghostty/, glance/, fastfetch/, ccstatusline/ configs
  # are NOT symlinked here because they already live in ~/.config/ (the dotfiles repo).
  # On a new machine, cloning the repo to ~/.config/ puts them in place automatically.
  # Claude/Codex configs live outside ~/.config, so ai-tools.nix links their
  # durable non-secret files from this repo into ~/.claude and ~/.codex.
  # obsidian.nix bootstraps the private Obsidian vault checkout and adds an
  # ignored ~/.config/obsidian-vault symlink for convenient access from dotfiles.
}
