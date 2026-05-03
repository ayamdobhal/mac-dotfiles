{ pkgs, ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  users.users.ayamdobhal = {
    isNormalUser = true;
    description = "Ayam Dobhal";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "docker" ];
  };

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    pciutils
    usbutils
    killall
    unzip
  ];
}
