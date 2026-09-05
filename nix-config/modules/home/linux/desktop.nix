{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    bluez
    brightnessctl
    cava
    commit-mono
    glib
    (ibm-plex.override {
      families = [
        "sans"
        "sans-condensed"
      ];
    })
    jq
    libnotify
    lm_sensors
    loupe
    material-symbols
    matugen
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nemo
    orbitron
    playerctl
  ];

  # Keep image opening deterministic for Nemo and other XDG-aware programs.
  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = [ pkgs.loupe ];
  };

  # Keep existing model settings; remove the retired OpenDesign bridge.
  home.file.".codex/config.toml".text = ''
    model = "gpt-5.6-sol"
    model_reasoning_effort = "high"
    approval_policy = "never"
    sandbox_mode = "danger-full-access"

    [projects."/home/ayam/nix"]
    trust_level = "trusted"

    [projects."/home/ayam/projects/mac-dotfiles"]
    trust_level = "trusted"
  '';
  home.file.".codex/skills/playwright".source = "${inputs.codex-skills}/skills/.curated/playwright";
  home.file.".codex/skills/screenshot".source = "${inputs.codex-skills}/skills/.curated/screenshot";
}
