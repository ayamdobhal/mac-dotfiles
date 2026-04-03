{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # nvim config lives in ~/.config/nvim/ (dotfiles repo) — no symlink needed
}
