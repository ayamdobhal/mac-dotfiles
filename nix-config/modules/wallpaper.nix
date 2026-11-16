{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Lives in the dotfiles checkout rather than the flake source so a 14 MB image
  # is not copied into the store on every rebuild.
  wallpaper = "${config.home.homeDirectory}/.config/wallpapers/dal-lake-shikara-night.png";
  desktoppr = "${pkgs.desktoppr}/bin/desktoppr";
in
{
  # macOS has no declarative wallpaper setting, so apply it on activation.
  # desktoppr sets the visible space on every display; other spaces keep
  # their picture until they are set too.
  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    wallpaper=${lib.escapeShellArg wallpaper}

    if [ ! -f "$wallpaper" ]; then
      echo "Wallpaper not found, leaving desktop picture alone: $wallpaper" >&2
    elif ! ${desktoppr} | grep -vqxF "$wallpaper"; then
      : # every display already shows it
    elif ! ${desktoppr} "$wallpaper"; then
      echo "Could not set wallpaper: $wallpaper" >&2
    fi
  '';
}
