{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "thonkpad";

  system.stateVersion = "25.11";
}
