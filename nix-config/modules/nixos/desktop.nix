{ pkgs, ... }:

let
  niriPackage = pkgs.niri;
in
{
  hardware.graphics.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs.dconf.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.upower.enable = true;

  # Run portals system-wide so the document portal has access to fusermount3.
  # The GNOME file chooser delegates to Nautilus, which is not installed on
  # this Nemo-based desktop, so use the self-contained GTK chooser instead.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # Start the lightweight Wayland session automatically on boot. If the
  # session exits, greetd falls back to a small text-based login prompt.
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${niriPackage}/bin/niri-session";
        user = "ayam";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${niriPackage}/bin/niri-session";
        user = "greeter";
      };
    };
  };
}
