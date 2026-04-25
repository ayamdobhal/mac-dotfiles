{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
  };

  # nvim config lives in ~/.config/nvim/ (dotfiles repo) — no symlink needed
}
