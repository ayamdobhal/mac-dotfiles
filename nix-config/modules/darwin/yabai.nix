{ pkgs, ... }: {
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
    extraConfig = ''
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

      yabai -m config layout bsp
      yabai -m config window_placement second_child

      # padding
      yabai -m config top_padding    10
      yabai -m config bottom_padding 10
      yabai -m config left_padding   10
      yabai -m config right_padding  10

      # window opacity
      yabai -m config window_opacity on
      yabai -m config active_window_opacity 1.0
      yabai -m config normal_window_opacity 1.0

      yabai -m rule --add app="^Code$" opacity=0.8
      yabai -m rule --add app="^Cursor$" opacity=0.8

      # mouse
      yabai -m config mouse_modifier alt
      yabai -m config mouse_action1 move
      yabai -m config mouse_action2 resize
      yabai -m config mouse_follows_focus off

      # rules
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off

      # external bar (sketchybar)
      yabai -m config external_bar all:30:0
    '';
  };

  # Patch yabai SA PAC ABI v1 -> v0 (yabai 7.1.17 + Sequoia bug)
  # Runs as root during activation, before yabai service starts
  system.activationScripts.postActivation.text = ''
    LOADER="/Library/ScriptingAdditions/yabai.osax/Contents/MacOS/loader"
    if [ -f "$LOADER" ]; then
      printf '\x80' | dd of="$LOADER" bs=1 seek=32 count=1 conv=notrunc 2>/dev/null
      printf '\x80' | dd of="$LOADER" bs=1 seek=65547 count=1 conv=notrunc 2>/dev/null
      codesign -f -s - "$LOADER" 2>/dev/null
      echo "Patched yabai scripting addition PAC ABI"
    fi
  '';
}
