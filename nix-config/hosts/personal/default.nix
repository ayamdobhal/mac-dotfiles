{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Determinate Nix manages its own daemon
  nix.enable = false;

  system.primaryUser = "ayamdobhal";

  users.users.ayamdobhal = {
    home = "/Users/ayamdobhal";
  };

  # macOS-only packages
  environment.systemPackages = with pkgs; [
    switchaudio-osx
  ];

  system.stateVersion = 6;
}
