{ pkgs, ... }: {
  home.packages = with pkgs; [
    # core utils
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
    tree-sitter
    lua5_4
    luarocks
    basedpyright
    rust-analyzer
    elixir-ls
    elixir
    vtsls

    # fonts
    nerd-fonts.hack
  ];
}
