{ config, lib, ... }:
let
  cfg = config.dotfiles.rebuild;
in
{
  # Where `nrs` switches from. A flake layered on top of this one (see
  # lib.mkHome in flake.nix) points these at itself.
  options.dotfiles.rebuild = {
    flake = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.config/nix-config";
      description = "Flake that `nrs` switches from. Expanded by the shell.";
    };
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments `nrs` passes to `home-manager switch`. Expanded by the shell.";
    };
  };

  config.programs.zsh.initContent = ''
    # Rebuild helper. `nrs` -> auto-detect host, `nrs <hostname>` -> explicit
    # (ayam-magbog-work / ayam-magbog-personal). No sudo: home-manager only
    # touches the home directory.
    nrs() {
      local host="''${1:-$(scutil --get LocalHostName 2>/dev/null)}"
      home-manager switch --flake "${cfg.flake}#$USER@$host" -b backup ${
        lib.concatMapStringsSep " " (arg: ''"${arg}"'') cfg.extraArgs
      }
    }
  '';
}
