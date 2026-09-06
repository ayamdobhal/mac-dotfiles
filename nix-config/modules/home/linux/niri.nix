{ lib, pkgs, ... }:
let
  shortcuts = pkgs.writeShellApplication {
    name = "niri-shortcuts";
    runtimeInputs = [
      pkgs.niri
      pkgs.python3
    ];
    text = ''exec python3 ${./niri-shortcuts.py} "$@"'';
  };
  workspaceBinds = builtins.listToAttrs (
    lib.concatMap (
      i:
      let
        key = if i == 10 then "0" else toString i;
      in
      [
        {
          name = "Alt+${key}";
          value.focus-workspace = "desk-${toString i}";
        }
        {
          name = "Alt+Shift+${key}";
          value.move-window-to-workspace = {
            _args = [ "desk-${toString i}" ];
            _props.focus = false;
          };
        }
      ]
    ) (lib.range 1 10)
  );
in

{
  home.packages = [ shortcuts ];
  wayland.windowManager.niri = {
    enable = true;
    # Portals are configured by NixOS so the document portal can use the
    # system-provided FUSE helper.
    portalPackage = null;
    settings = {
      prefer-no-csd = { };
      input.focus-follows-mouse = { };
      layout.gaps = 8;
      hotkey-overlay.skip-at-startup = { };

      _children = (map (i: { workspace._args = [ "desk-${toString i}" ]; }) (lib.range 1 10)) ++ [
        {
          spawn-at-startup._args = [
            "app2unit"
            "--"
            "gnome-keyring-daemon"
            "--start"
            "--components=secrets"
          ];
        }
        {
          spawn-at-startup._args = [
            "app2unit"
            "--"
            "mako"
          ];
        }
        {
          # Keep the shell tied to the graphical session and represented by a
          # systemd user unit. Mako and fuzzel remain active fallbacks.
          spawn-at-startup._args = [
            "app2unit"
            "-t"
            "service"
            "-u"
            "app-niri-quickshell.service"
            "-p"
            "Restart=on-failure"
            "-p"
            "RestartSec=1s"
            "--"
            "${pkgs.quickshell}/bin/qs"
            "--no-duplicate"
            "--config"
            "nerv"
          ];
        }
        {
          spawn-at-startup._args = [
            "app2unit"
            "--"
            "org.kde.polkit-kde-authentication-agent-1.desktop"
          ];
        }
        {
          spawn-at-startup._args = [
            "app2unit"
            "--"
            "wl-paste"
            "--type"
            "text"
            "--watch"
            "cliphist"
            "store"
          ];
        }
        {
          spawn-at-startup._args = [
            "app2unit"
            "--"
            "wl-paste"
            "--type"
            "image"
            "--watch"
            "cliphist"
            "store"
          ];
        }
      ];

      binds = workspaceBinds // {
        "Alt+F".toggle-windowed-fullscreen = { };
        "Alt+T".toggle-window-floating = { };
        "Ctrl+Left".focus-column-left = { };
        "Ctrl+Right".focus-column-right = { };
        "Ctrl+Up".focus-window-up = { };
        "Ctrl+Down".focus-window-down = { };
        "Alt+Shift+Left".move-column-left = { };
        "Alt+Shift+Right".move-column-right = { };
        "Alt+Shift+Up".move-window-up = { };
        "Alt+Shift+Down".move-window-down = { };
        "Ctrl+Alt+Shift+H".spawn = [
          "${shortcuts}/bin/niri-shortcuts"
          "swap"
        ];
        "Ctrl+Alt+U".set-window-width = "+80";
        "Ctrl+Alt+P".set-window-width = "-80";
        "Ctrl+Alt+I".set-window-height = "-80";
        "Ctrl+Alt+O".set-window-height = "+80";
        "Alt+Tab".focus-workspace-previous = { };
        "Mod+Tab".spawn = [
          "${shortcuts}/bin/niri-shortcuts"
          "cycle"
        ];
        "Mod+Shift+Return".spawn = [ "${pkgs.ghostty}/bin/ghostty" ];
        "Ctrl+Alt+N".spawn = [
          "${shortcuts}/bin/niri-shortcuts"
          "new"
        ];
        "Ctrl+Shift+R".spawn = [
          "${shortcuts}/bin/niri-shortcuts"
          "reload"
        ];
        "XF86AudioMute".spawn = [
          "${pkgs.wireplumber}/bin/wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SINK@"
          "toggle"
        ];
        "XF86AudioLowerVolume".spawn = [
          "${pkgs.wireplumber}/bin/wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%-"
        ];
        "XF86AudioRaiseVolume".spawn = [
          "${pkgs.wireplumber}/bin/wpctl"
          "set-volume"
          "-l"
          "1.0"
          "@DEFAULT_AUDIO_SINK@"
          "5%+"
        ];
        "XF86MonBrightnessDown".spawn = [
          "${pkgs.brightnessctl}/bin/brightnessctl"
          "set"
          "5%-"
        ];
        "XF86MonBrightnessUp".spawn = [
          "${pkgs.brightnessctl}/bin/brightnessctl"
          "set"
          "+5%"
        ];
        "Mod+D".spawn = [
          "${pkgs.quickshell}/bin/qs"
          "--config"
          "nerv"
          "ipc"
          "call"
          "nerv"
          "toggleLauncher"
        ];
        # Explicit fallback while desktop-action and failure-state parity are
        # still being validated in the Quickshell launcher.
        "Mod+Shift+D".spawn = [ "fuzzel" ];
        "Mod+Shift+N".spawn = [
          "${pkgs.quickshell}/bin/qs"
          "--config"
          "nerv"
          "ipc"
          "call"
          "nerv"
          "toggleIncidents"
        ];
        "Mod+Shift+Space".spawn = [
          "${pkgs.quickshell}/bin/qs"
          "--config"
          "nerv"
          "ipc"
          "call"
          "nerv"
          "toggleQuickView"
        ];
        "Mod+Shift+T".spawn = [
          "${pkgs.quickshell}/bin/qs"
          "--config"
          "nerv"
          "ipc"
          "call"
          "nerv"
          "toggleQuickToggles"
        ];
        "Mod+Comma".spawn = [
          "${pkgs.quickshell}/bin/qs"
          "--config"
          "nerv"
          "ipc"
          "call"
          "nerv"
          "toggleMaintenance"
        ];
        "Mod+Return".spawn = [ "${pkgs.ghostty}/bin/ghostty" ];
        "Mod+V".spawn = [ "cliphist-fuzzel-img" ];
        "Mod+F".fullscreen-window = { };
        "Mod+M".maximize-window-to-edges = { };
        "Mod+Q".close-window = { };
        "Mod+Left".focus-column-left = { };
        "Mod+Down".focus-window-down = { };
        "Mod+Up".focus-window-up = { };
        "Mod+Right".focus-column-right = { };
        "Mod+Shift+E".quit = { };
      };
    };
  };
}
