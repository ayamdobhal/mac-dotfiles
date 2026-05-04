{ lib, pkgs, ... }:

# Hyprland user config. Declared via xdg.configFile rather than the
# wayland.windowManager.hyprland module so the .conf is plain text and easy
# to iterate on. Gated to Linux — on Mac this evaluates to nothing.
{
  config = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
    xdg.configFile."hypr/hyprland.conf".text = ''
      # ── monitor ────────────────────────────────────────────────────────────
      # T480 panel is eDP-1. `preferred,auto,1` = native resolution at 1x scale.
      monitor=,preferred,auto,1

      # ── env ────────────────────────────────────────────────────────────────
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24

      # ── autostart ──────────────────────────────────────────────────────────
      exec-once = waybar
      exec-once = mako
      exec-once = hypridle
      exec-once = nm-applet --indicator
      # Wallpaper: enable once ~/.config/hypr/hyprpaper.conf exists.
      # exec-once = hyprpaper

      # ── input ──────────────────────────────────────────────────────────────
      input {
        kb_layout = us
        follow_mouse = 1
        sensitivity = 0
        touchpad {
          natural_scroll = true
          tap-to-click = true
          disable_while_typing = true
        }
      }

      # ── general ────────────────────────────────────────────────────────────
      general {
        gaps_in = 4
        gaps_out = 8
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        layout = dwindle
        allow_tearing = false
      }

      decoration {
        rounding = 6
        blur {
          enabled = true
          size = 3
          passes = 1
        }
      }

      animations {
        enabled = yes
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
      }

      dwindle {
        pseudotile = yes
        preserve_split = yes
      }

      gestures {
        workspace_swipe = on
      }

      misc {
        force_default_wallpaper = 0
        disable_hyprland_logo = true
      }

      # ── keybinds ───────────────────────────────────────────────────────────
      $mod = SUPER

      bind = $mod, Return, exec, kitty
      bind = $mod, Q, killactive
      bind = $mod SHIFT, E, exit
      bind = $mod, E, exec, nautilus
      bind = $mod, R, exec, wofi --show drun
      bind = $mod, V, togglefloating
      bind = $mod, P, pseudo
      bind = $mod, J, togglesplit
      bind = $mod, F, fullscreen
      bind = $mod, L, exec, hyprlock

      # focus
      bind = $mod, left,  movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up,    movefocus, u
      bind = $mod, down,  movefocus, d
      bind = $mod, h,     movefocus, l
      bind = $mod, l,     movefocus, r
      bind = $mod, k,     movefocus, u
      bind = $mod, j,     movefocus, d

      # workspaces 1..9
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9

      # move to workspace
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9

      # scroll through workspaces
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up,   workspace, e-1

      # mouse
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      # screenshots (hyprshot)
      bind = , Print, exec, hyprshot -m output
      bind = SHIFT, Print, exec, hyprshot -m region
      bind = $mod, Print, exec, hyprshot -m window

      # T480 fn-row: brightness, volume, media, mic.
      bindel = , XF86MonBrightnessUp,   exec, brightnessctl set 5%+
      bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
      bindel = , XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindel = , XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindl  = , XF86AudioMute,         exec, wpctl set-mute   @DEFAULT_AUDIO_SINK@ toggle
      bindl  = , XF86AudioMicMute,      exec, wpctl set-mute   @DEFAULT_AUDIO_SOURCE@ toggle
      bindl  = , XF86AudioPlay,         exec, playerctl play-pause
      bindl  = , XF86AudioNext,         exec, playerctl next
      bindl  = , XF86AudioPrev,         exec, playerctl previous
    '';

    xdg.configFile."hypr/hypridle.conf".text = ''
      general {
        lock_cmd       = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd  = hyprctl dispatch dpms on
      }

      # dim screen at 5min
      listener {
        timeout    = 300
        on-timeout = brightnessctl -s set 10
        on-resume  = brightnessctl -r
      }

      # lock at 10min
      listener {
        timeout    = 600
        on-timeout = loginctl lock-session
      }

      # screen off at 15min
      listener {
        timeout    = 900
        on-timeout = hyprctl dispatch dpms off
        on-resume  = hyprctl dispatch dpms on
      }

      # suspend at 30min (on battery this saves the world)
      listener {
        timeout    = 1800
        on-timeout = systemctl suspend
      }
    '';

    xdg.configFile."hypr/hyprlock.conf".text = ''
      background {
        monitor =
        color   = rgba(25, 20, 20, 1.0)
      }

      input-field {
        monitor =
        size = 250, 60
        outline_thickness = 2
        dots_size = 0.2
        dots_spacing = 0.2
        outer_color = rgba(0, 0, 0, 0)
        inner_color = rgba(255, 255, 255, 0.1)
        font_color  = rgb(200, 200, 200)
        fade_on_empty = false
        placeholder_text = <i>password...</i>
        position = 0, -20
        halign   = center
        valign   = center
      }

      label {
        monitor =
        text = $TIME
        color = rgba(200, 200, 200, 1.0)
        font_size = 55
        font_family = Hack Nerd Font
        position = 0, 80
        halign   = center
        valign   = center
      }

      label {
        monitor =
        text = Hi $USER
        color = rgba(200, 200, 200, 1.0)
        font_size = 20
        font_family = Hack Nerd Font
        position = 0, 0
        halign   = center
        valign   = center
      }
    '';
  };
}
