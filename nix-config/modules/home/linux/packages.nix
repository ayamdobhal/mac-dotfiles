{ pkgs, ... }: {
  imports = [ ../shared/packages.nix ];
  home.packages = with pkgs; [
    # Required by the shared Neovim Treesitter parser installer.
    gcc
    discord
    claude-code
    nerd-fonts.hack
    nerd-fonts.blex-mono
    noto-fonts
    noto-fonts-color-emoji
    liberation_ttf
  ];
  xdg.configFile."nvim".source = ../../../../nvim;
  xdg.configFile."fastfetch".source = ../../../../fastfetch;
}
