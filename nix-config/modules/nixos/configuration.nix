{ pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ../../hosts/thonkpad/hardware-configuration.nix
    ./packages.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "thonkpad";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = true;
  };

  time.timeZone = "Asia/Kolkata";

  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.ayam = {
    isNormalUser = true;
    description = "Ayam";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [ "https://codex-cli.cachix.org" ];
      extra-trusted-public-keys = [
        "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Keep this at the version used when the system was first installed.
  system.stateVersion = "26.05";
}
