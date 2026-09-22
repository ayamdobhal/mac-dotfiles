{ pkgs, ... }: {
  home.packages = with pkgs; [
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
    bun
    tree-sitter
    lua5_5
    lua5_5.pkgs.luarocks
    basedpyright
    rust-analyzer
    elixir-ls
    beamPackages.elixir
    vtsls
  ];
}
