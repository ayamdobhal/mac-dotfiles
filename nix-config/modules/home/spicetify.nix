{ spicetify-nix, pkgs, ... }:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [ spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;
    theme = {
      name = "marketplace";
      src = pkgs.writeTextDir "color.ini" "";
      injectCss = false;
      injectThemeJs = false;
      replaceColors = false;
      overwriteAssets = false;
    };
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
  };
}
