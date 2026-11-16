{ ... }:
{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/rebuild.nix
    ./modules/git.nix
    ./modules/neovim.nix
    ./modules/dev.nix
    ./modules/wallpaper.nix

    # macOS desktop
    ./modules/defaults.nix
    ./modules/homebrew.nix
    ./modules/yabai.nix
    ./modules/skhd.nix
    ./modules/glance.nix
    ./modules/caffeinate.nix
  ];

  home.stateVersion = "25.05";
  home.username = "ayamdobhal";
  home.homeDirectory = "/Users/ayamdobhal";

  programs.home-manager.enable = true;
  xdg.enable = true;

  # Copy nix-built .app bundles into ~/Applications/Home Manager Apps so
  # Spotlight and Raycast index them (symlinks are not indexed).
  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;

  # Skip home-manager's man-page generation. It pulls in nixosOptionsDoc which
  # emits a "builtins.derivation … options.json without proper context" warning
  # on every rebuild. We don't read the HM man pages.
  manual.manpages.enable = false;

  # NOTE: nvim/, ghostty/, glance/, fastfetch/, ccstatusline/, skhd/ and yabai/
  # configs are NOT symlinked here because they already live in ~/.config/ (the
  # dotfiles repo). On a new machine, cloning the repo to ~/.config/ puts them
  # in place automatically, and edits apply without a rebuild.
}
