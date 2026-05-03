{ ... }: {
  imports = [
    ./system.nix
    ./hardware.nix
    ./hyprland.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import ../../overlays) ];
}
