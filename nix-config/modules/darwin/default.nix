{ ... }: {
  imports = [
    ./system.nix
    ./homebrew.nix
    ./yabai.nix
    ./skhd.nix
    ./sketchybar.nix
  ];

  nixpkgs.overlays = [ (import ../../overlays) ];
}
