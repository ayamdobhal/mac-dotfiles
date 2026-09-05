{ lib, pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."ghostty/config".text = lib.mkForce (
    builtins.readFile ./ghostty.conf + "\ncommand = ${pkgs.zsh}/bin/zsh\n"
  );
}
