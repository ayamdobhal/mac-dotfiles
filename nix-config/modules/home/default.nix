{ ... }: {
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./neovim.nix
    ./dev.nix
  ];

  home.stateVersion = "25.05";
  home.username = "ayamdobhal";
  home.homeDirectory = "/Users/ayamdobhal";

  # NOTE: nvim/, ghostty/, sketchybar/, fastfetch/, ccstatusline/ configs
  # are NOT symlinked here because they already live in ~/.config/ (the dotfiles repo).
  # On a new machine, cloning the repo to ~/.config/ puts them in place automatically.
}
