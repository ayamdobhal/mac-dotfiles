{ inputs, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
    ./terminal.nix
    ../dev.nix
    ../neovim.nix
    ./desktop.nix
    ./niri.nix
    ./quickshell.nix
  ];

  home = {
    username = "ayam";
    homeDirectory = "/home/ayam";

    packages = [
      inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.app2unit
      pkgs.cliphist
      pkgs.git
      pkgs.gnome-keyring
      pkgs.kdePackages.polkit-kde-agent-1
      pkgs.mako
      pkgs.wl-clipboard
    ];

    # Keep this at the version used when Home Manager was first introduced.
    stateVersion = "26.05";
  };

  programs.firefox.enable = true;
  programs.fuzzel = {
    enable = true;
    # Parity fallback for the Quickshell Column Insertion Gate. Keep this
    # visually consistent with the shell so fallback operation is explicit,
    # but does not look like an unrelated desktop surface.
    settings = {
      main = {
        font = "IBM Plex Sans Condensed:size=12";
        "use-bold" = true;
        prompt = "INSERT //";
        placeholder = "APPLICATION / ACTION / EVIDENCE";
        message = "NERV OPERATIONS // COLUMN INSERTION GATE FALLBACK";
        terminal = "${pkgs.ghostty}/bin/ghostty -e";
        "launch-prefix" = "app2unit --fuzzel-compat --";
        width = 52;
        lines = 12;
        "horizontal-pad" = 20;
        "vertical-pad" = 14;
        "inner-pad" = 8;
        "line-height" = 36;
        "icons-enabled" = true;
        "show-actions" = true;
        "match-counter" = true;
        fields = "filename,name,generic,keywords,comment";
        layer = "overlay";
        "exit-on-keyboard-focus-loss" = true;
      };
      colors = {
        background = "271811dc";
        text = "f0e5d2ff";
        message = "f09a3eff";
        prompt = "e3e33bff";
        placeholder = "ad9b8dff";
        input = "f0e5d2ff";
        match = "e3e33bff";
        selection = "e62c3bff";
        "selection-text" = "0c0a0bff";
        "selection-match" = "e3e33bff";
        counter = "ad9b8dff";
        border = "e62c3bff";
      };
      border = {
        width = 2;
        radius = 0;
        "selection-radius" = 0;
      };
    };
  };
  programs.home-manager.enable = true;
}
