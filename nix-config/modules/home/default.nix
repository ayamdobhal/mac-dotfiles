{ pkgs, ... }: {
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./neovim.nix
    ./dev.nix
    ./hyprland.nix
  ];

  home.stateVersion = "25.05";
  home.username = "ayamdobhal";
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/ayamdobhal"
    else "/home/ayamdobhal";

  # Skip home-manager's man-page generation. It pulls in nixosOptionsDoc which
  # emits a "builtins.derivation … options.json without proper context" warning
  # on every rebuild. We don't read the HM man pages.
  manual.manpages.enable = false;

  # NOTE: nvim/, ghostty/, sketchybar/, fastfetch/, ccstatusline/ configs
  # are NOT symlinked here because they already live in ~/.config/ (the dotfiles repo).
  # On a new machine, cloning the repo to ~/.config/ puts them in place automatically.
}
