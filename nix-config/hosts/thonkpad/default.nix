{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "thonkpad";

  # T480: Intel Kaby Lake R CPU + Intel UHD 620 iGPU.
  hardware.cpu.intel.updateMicrocode = true;
  services.thermald.enable = true;

  # VA-API hardware video acceleration (Intel iGPU).
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    libvdpau-va-gl
  ];

  system.stateVersion = "25.11";
}
