{ pkgs, claude-code, ... }: {
  home.packages = [
    claude-code.packages.${pkgs.system}.default
  ] ++ (with pkgs; [
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
    lua5_4
    luarocks
    basedpyright
    rust-analyzer
    elixir-ls
    elixir

    # fonts
    nerd-fonts.hack
  ]);
}
