{ ... }: {
  imports = [
    ./system.nix
    ./caffeinate.nix
    ./homebrew.nix
    ./yabai.nix
    ./skhd.nix
    ./glance.nix
  ];

  nixpkgs.overlays = [ (import ../../overlays) ];
}
