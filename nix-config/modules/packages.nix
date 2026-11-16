{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # core utils
    bat
    glow
    bottom
    fd
    jq
    ripgrep
    tree
    wget
    lazygit
    gh
    fastfetch
    awscli2
    ngrok
    yt-dlp
    ffmpeg
    switchaudio-osx

    # languages and language servers
    bun
    tree-sitter
    lua5_5
    basedpyright
    rust-analyzer
    elixir-ls
    beamPackages.elixir
    vtsls

    # xAI's coding agent (`grok`); unfree
    grok-build

    # fonts
    nerd-fonts.hack
  ];

  # glow reads its config from ~/Library/Preferences on macOS.
  # width: 0 in the *config* makes glow wrap at the terminal width (capped at
  # 120 cols); the same value on the CLI (-w 0) disables wrapping instead.
  home.file."Library/Preferences/glow/glow.yml" = {
    force = true;
    text = ''
      style: "auto"
      mouse: false
      pager: false
      width: 0
      all: false
    '';
  };
}
