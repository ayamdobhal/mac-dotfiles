{ pkgs, ... }: {
  imports = [ ./shared/packages.nix ];
  home.packages = with pkgs; [
    # core utils
    awscli2
    ngrok
    yt-dlp
    ffmpeg

    # neovim / sketchybar deps

    # fonts
    nerd-fonts.hack
    sketchybar-app-font
  ];
}
