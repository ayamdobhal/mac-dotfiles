{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.hyprlock.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    wofi
    mako
    hyprpaper
    hyprshot
    wl-clipboard
    grim
    slurp
    brightnessctl
    playerctl
    pavucontrol
    networkmanagerapplet
    kitty
    hypridle
  ];
}
