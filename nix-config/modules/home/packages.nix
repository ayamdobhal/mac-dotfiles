{ pkgs, ... }: {
  home.packages = with pkgs; [
    # core utils
    claude-code
    bat
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
    bun

    # neovim / sketchybar deps
    lua5_4
    luarocks
    basedpyright
    rust-analyzer
    elixir-ls
    elixir

    # fonts
    nerd-fonts.hack
  ];
}
