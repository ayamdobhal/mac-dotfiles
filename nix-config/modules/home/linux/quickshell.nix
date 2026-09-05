{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Personal wallpaper override. It is intentionally outside the flake source
  # and ignored by Git; the shell falls back to its void color when absent.
  localWallpaperPath = "${config.home.homeDirectory}/.local/share/nerv/wallpaper.png";

  # Approved MAGI Column Synchrograph tokens. QML consumes only this generated
  # object; visual components do not carry private copies of the palette,
  # spacing scale, typography, motion durations, or normalized state names.
  tokensQml = pkgs.writeTextDir "Tokens.qml" ''
    import QtQuick

    QtObject {
      readonly property color voidColor: "#120f10"
      readonly property color inkColor: "#21150f"
      readonly property color borderColor: "#815735"
      readonly property color boneColor: "#f0e5d2"
      readonly property color mutedColor: "#c2a887"
      readonly property color signalRed: "#e62c3b"
      readonly property color signalRedDeep: "#a4112c"
      readonly property color signalOrange: "#f09a3e"
      readonly property color hazardYellow: "#e3e33b"
      readonly property color acidGreen: "#a4dc31"
      readonly property color recoveryCobalt: "#5477c9"
      readonly property color identityPurple: "#874bb5"

      // Smoked amber polycarbonate material. Niri does not currently expose a
      // compositor backdrop-blur protocol, so production uses the approved
      // warm translucent tint and the same-geometry solid fallback.
      property bool reducedTransparency: ${lib.boolToString config.nervDesktop.reducedTransparency}
      readonly property real materialOpacity: ${toString config.nervDesktop.materialOpacity}
      readonly property int blurSpine: 16
      readonly property int blurPrimary: 22
      readonly property int blurSecondary: 10
      readonly property color materialSolidColor: "#39251b"
      readonly property color materialSpineColor: reducedTransparency ? materialSolidColor : Qt.rgba(0.20, 0.12, 0.08, scaledAlpha(0.76))
      readonly property color materialPrimaryColor: reducedTransparency ? materialSolidColor : Qt.rgba(0.23, 0.14, 0.09, scaledAlpha(0.67))
      readonly property color materialSecondaryColor: reducedTransparency ? "#332117" : Qt.rgba(0.21, 0.12, 0.08, scaledAlpha(0.50))
      readonly property color materialEvidenceColor: reducedTransparency ? "#2a1a13" : Qt.rgba(0.16, 0.09, 0.06, scaledAlpha(0.70))
      readonly property color materialDenseColor: reducedTransparency ? "#281910" : Qt.rgba(0.15, 0.085, 0.05, scaledAlpha(0.82))
      readonly property color materialNoticeColor: reducedTransparency ? "#2b1b13" : Qt.rgba(0.16, 0.09, 0.06, scaledAlpha(0.86))
      readonly property color surfaceColor: materialSecondaryColor
      readonly property color surfaceRaisedColor: reducedTransparency ? "#4a2d1c" : Qt.rgba(0.29, 0.17, 0.10, scaledAlpha(0.68))

      readonly property string displayFont: "IBM Plex Sans Condensed"
      readonly property string bodyFont: "IBM Plex Sans"
      readonly property string monoFont: "CommitMono"
      readonly property string identityFont: "Orbitron"

      readonly property int spineWidth: 96
      readonly property int target: 36
      readonly property int targetPrimary: 44
      readonly property int space4: 4
      readonly property int space8: 8
      readonly property int space12: 12
      readonly property int space16: 16
      readonly property int space24: 24
      readonly property int space32: 32
      readonly property int cutSmall: 8
      readonly property int cutMedium: 14
      readonly property int cutLarge: 26

      // This is the complete reduced-motion switch. Every duration in the
      // shell resolves through these values; no component loops indefinitely.
      readonly property bool reducedMotion: ${lib.boolToString config.nervDesktop.reducedMotion}
      readonly property int motionFast: reducedMotion ? 0 : 140
      readonly property int motionClose: reducedMotion ? 0 : 160
      readonly property int motionStack: reducedMotion ? 0 : 220
      readonly property int motionPanel: reducedMotion ? 0 : 280
      readonly property int motionWorkspace: reducedMotion ? 0 : 340
      readonly property int motionTrace: reducedMotion ? 0 : 420

      readonly property string stateUnknown: "unknown"
      readonly property string stateUnavailable: "unavailable"
      readonly property string stateBusy: "busy"
      readonly property string stateReady: "ready"
      readonly property string stateWarning: "warning"
      readonly property string stateError: "error"

      function scaledAlpha(base) {
        return Math.min(1, Math.max(0.35, base * materialOpacity))
      }

      function stateColor(state) {
        if (state === stateReady)
          return acidGreen
        if (state === stateWarning || state === stateBusy)
          return signalOrange
        if (state === stateError)
          return signalRed
        if (state === stateUnavailable)
          return mutedColor
        return recoveryCobalt
      }
    }
  '';

  runtimeQml = pkgs.writeTextDir "Runtime.qml" ''
    import QtQuick

    QtObject {
      readonly property string niri: "${pkgs.niri}/bin/niri"
      readonly property string app2unit: "${pkgs.app2unit}/bin/app2unit"
      readonly property string brightnessctl: "${pkgs.brightnessctl}/bin/brightnessctl"
      readonly property string makoctl: "${pkgs.mako}/bin/makoctl"
      readonly property string sensors: "${pkgs.lm_sensors}/bin/sensors"
      readonly property string systemdInhibit: "${pkgs.systemd}/bin/systemd-inhibit"
      readonly property string sleep: "${pkgs.coreutils}/bin/sleep"
      readonly property string uname: "${pkgs.coreutils}/bin/uname"
      readonly property string readlink: "${pkgs.coreutils}/bin/readlink"
      readonly property string wallpaperPath: "${localWallpaperPath}"
      readonly property url wallpaper: "file://${localWallpaperPath}"
      readonly property var launchTargets: [
        { "label": "TERMINAL", "detail": "GHOSTTY / NEW COLUMN", "kind": "RECENT", "command": ["${pkgs.ghostty}/bin/ghostty"] },
        { "label": "BROWSER", "detail": "FIREFOX / NEW COLUMN", "kind": "RECENT", "command": ["${pkgs.firefox}/bin/firefox"] },
        { "label": "FILES", "detail": "NEMO / NEW COLUMN", "kind": "RECENT", "command": ["${pkgs.nemo}/bin/nemo"] },
        { "label": "CODE", "detail": "NEOVIM / NEW COLUMN", "kind": "APPLICATION", "command": ["${pkgs.ghostty}/bin/ghostty", "-e", "${pkgs.neovim}/bin/nvim"] },
        { "label": "NIX REPOSITORY", "detail": "DOTFILES / NEOVIM", "kind": "SETTING", "command": ["${pkgs.ghostty}/bin/ghostty", "--working-directory=/home/ayam/projects/mac-dotfiles", "-e", "${pkgs.neovim}/bin/nvim", "/home/ayam/projects/mac-dotfiles/nix-config/flake.nix"] },
        { "label": "RELOAD NIRI CONFIG", "detail": "DECLARATIVE CONFIG RE-READ", "kind": "COMMAND", "command": ["${pkgs.niri}/bin/niri", "msg", "action", "load-config-file"] },
        { "label": "RELOAD WALLPAPER", "detail": "INVALIDATE LOCAL IMAGE CACHE", "kind": "COMMAND", "command": ["${pkgs.quickshell}/bin/qs", "--config", "nerv", "ipc", "call", "nerv", "reloadWallpaper"] }
      ]
    }
  '';

  # Copy the authored tree into one store directory before adding generated
  # files. Keeping shell.qml and Tokens.qml under the same canonical QML URL is
  # important: a symlink join would make local type discovery follow shell.qml
  # back to a source store path where the generated types do not exist.
  quickshellConfig = pkgs.runCommand "nerv-quickshell-config" { } ''
    mkdir -p "$out"
    cp -R ${./quickshell}/. "$out/"
    chmod -R u+w "$out"
    cp ${tokensQml}/Tokens.qml "$out/Tokens.qml"
    cp ${runtimeQml}/Runtime.qml "$out/Runtime.qml"
  '';
in
{
  options.nervDesktop.reducedMotion = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Disable all NERV shell travel, trace, and reveal motion.";
  };

  options.nervDesktop.reducedTransparency = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Use opaque warm-umber shell materials without changing chassis geometry or motion.";
  };

  options.nervDesktop.materialOpacity = lib.mkOption {
    type = lib.types.float;
    default = 1.0;
    description = "Multiplier for the approved Quickshell smoked-material alpha values.";
  };

  config = {
    home.packages = [ pkgs.quickshell ];

    # Home Manager replaces store-backed QML symlinks atomically. Quickshell's
    # file watcher remains attached to the previous canonical store paths, and
    # an in-process hard reload can exit while those paths change. Niri starts a
    # stable app2unit service, so restart that graphical-session unit only after
    # the new links are active. A missing session or inactive unit is a no-op.
    home.activation.reloadNervDesktopSurfaces = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      nerv_uid="$(${pkgs.coreutils}/bin/id -u)"
      nerv_runtime_dir="/run/user/$nerv_uid"
      if [ -d "$nerv_runtime_dir" ]; then
        if XDG_RUNTIME_DIR="$nerv_runtime_dir" ${pkgs.systemd}/bin/systemctl --user \
          --quiet is-active app-niri-quickshell.service; then
          XDG_RUNTIME_DIR="$nerv_runtime_dir" ${pkgs.systemd}/bin/systemctl --user \
            restart app-niri-quickshell.service
          echo "Restarted the NERV Quickshell graphical-session unit"
        fi

        # Mako remains the notification D-Bus owner until the Quickshell
        # server reaches parity. Reload its generated theme and expiry policy
        # without taking ownership of graphical-session startup here.
        if [ -S "$nerv_runtime_dir/bus" ]; then
          if XDG_RUNTIME_DIR="$nerv_runtime_dir" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=$nerv_runtime_dir/bus" \
            ${pkgs.mako}/bin/makoctl reload >/dev/null 2>&1; then
            echo "Reloaded the NERV mako notification fallback"
          fi
        fi
      fi
    '';

    xdg.configFile = {
      "quickshell/nerv" = {
        source = quickshellConfig;
        recursive = true;
      };
      "mako/config".text = ''
        # Incident Echelon popup fallback. The independent Quickshell surface
        # provides history while mako continues to own live notifications.
        font=IBM Plex Sans Condensed 11
        background-color=#271811dc
        text-color=#f0e5d2ff
        border-color=#e62c3bff
        border-size=3
        border-radius=0
        width=420
        height=180
        outer-margin=18
        margin=0,0,8
        padding=16
        anchor=top-right
        layer=overlay
        max-visible=4
        max-history=50
        default-timeout=6000
        ignore-timeout=1
        progress-color=over #f09a3eff
        icons=1
        max-icon-size=42
        icon-location=left
        markup=1
        actions=1
        history=1
        format=<span foreground="#f09a3e">%a // INCIDENT</span>\n<b>%s</b>\n%b

        [urgency=low]
        border-color=#5477c9ff
        default-timeout=4000

        [urgency=normal]
        border-color=#e62c3bff
        default-timeout=6000

        [urgency=critical]
        background-color=#a4112cf5
        text-color=#f0e5d2ff
        border-color=#e3e33bff
        default-timeout=0

        [mode=do-not-disturb urgency=low]
        invisible=1

        [mode=do-not-disturb urgency=normal]
        invisible=1
      '';
    };
  };
}
