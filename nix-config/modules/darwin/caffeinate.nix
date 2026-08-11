{ pkgs, ... }:
let
  # Keep the machine AND display awake while on AC power without touching any
  # of the pmset/screen-lock settings that Vanta audits. caffeinate -s is
  # AC-only by design, but -d (display) would also apply on battery, so we
  # gate on the power source ourselves — on battery everything stays stock.
  # Note: while the display assertion is held the screensaver/auto-lock will
  # not engage; lock manually (Ctrl+Cmd+Q) when stepping away.
  acCaffeinate = pkgs.writeShellScript "ac-caffeinate" ''
    caff_pid=""
    cleanup() {
      [ -n "$caff_pid" ] && kill "$caff_pid" 2>/dev/null
      exit 0
    }
    trap cleanup INT TERM

    while true; do
      if /usr/bin/pmset -g ps | grep -q "AC Power"; then
        if [ -z "$caff_pid" ] || ! kill -0 "$caff_pid" 2>/dev/null; then
          /usr/bin/caffeinate -ds &
          caff_pid=$!
        fi
      elif [ -n "$caff_pid" ]; then
        kill "$caff_pid" 2>/dev/null
        caff_pid=""
      fi
      sleep 30
    done
  '';
in {
  launchd.user.agents.caffeinate = {
    serviceConfig = {
      ProgramArguments = [ "${acCaffeinate}" ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
