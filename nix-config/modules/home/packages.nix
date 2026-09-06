{ pkgs, ... }: {
  imports = [ ./shared/packages.nix ];
  home.packages = with pkgs; [
    # core utils
    awscli2
    ngrok
    yt-dlp
    ffmpeg

    # fonts
    nerd-fonts.hack
  ];
}
