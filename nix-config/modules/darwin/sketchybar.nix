{ pkgs, ... }:
let
  sketchybarConfigScript = pkgs.writeShellScript "sketchybar-config" ''
    export PATH="${pkgs.lua5_5}/bin:${pkgs.python313}/bin:${pkgs.jq}/bin:${pkgs.gh}/bin:${pkgs.curl}/bin:${pkgs.bash}/bin:${pkgs.yabai}/bin:$PATH"
    export LUA_PATH="$HOME/.luarocks/share/lua/5.5/?.lua;$HOME/.luarocks/share/lua/5.5/?/init.lua;;"
    export LUA_CPATH="$HOME/.local/share/sketchybar_lua/?.so;$HOME/.luarocks/lib/lua/5.5/?.so;;"
    cd $HOME/.config/sketchybar
    exec ${pkgs.sketchybar}/bin/sketchybar --config $HOME/.config/sketchybar/sketchybarrc
  '';
in {
  launchd.user.agents.sketchybar-custom = {
    command = "${sketchybarConfigScript}";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  environment.systemPackages = [ pkgs.sketchybar ];
}
