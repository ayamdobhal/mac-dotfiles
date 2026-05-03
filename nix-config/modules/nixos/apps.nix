{ pkgs, ... }: {
  # GUI apps mirroring the Homebrew casks on Mac. Skipped: arc, raycast,
  # whatsapp, sf-symbols, sf fonts (no Linux equivalent or Apple proprietary).
  environment.systemPackages = with pkgs; [
    # browsers
    firefox
    google-chrome
    chromium
    # zen: not in nixpkgs at this revision — add the zen-browser flake later
    # (github:0xc000022070/zen-browser-flake)

    # comms
    discord
    telegram-desktop

    # media
    spotify
    spicetify-cli

    # utilities
    bitwarden-desktop
    proton-vpn

    # dev
    ghostty

    # file manager (Linux has no built-in Finder)
    nautilus
  ];

  services.tailscale.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # System fonts. Home-manager still installs nerd-fonts.hack at user level,
  # but SDDM and other system services need fonts available system-wide.
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    noto-fonts
    noto-fonts-color-emoji
    liberation_ttf
  ];
}
