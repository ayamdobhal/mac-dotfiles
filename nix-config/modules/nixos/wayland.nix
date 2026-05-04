{ ... }: {
  # Wayland-friendly app defaults. Set system-wide so SDDM-launched sessions
  # inherit them (user shells alone aren't enough for graphical sessions).
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";              # Electron (vscode, discord, slack)
    MOZ_ENABLE_WAYLAND = "1";          # Firefox
    QT_QPA_PLATFORM = "wayland;xcb";   # Qt: prefer wayland, fall back to X11
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11";       # GTK
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1"; # Java/IntelliJ won't render blank
  };
}
