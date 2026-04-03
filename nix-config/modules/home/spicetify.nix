{ spicetify-nix, pkgs, ... }:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [ spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
  };
}
