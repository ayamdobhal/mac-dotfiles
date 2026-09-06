{ config, ... }:
let
  home = config.users.users.${config.system.primaryUser}.home;
in
{
  # Install the locally built fork at ~/Applications/Glance.app first.
  # See glance/README.md for the Xcode build and widget installation steps.
  launchd.user.agents.glance = {
    serviceConfig = {
      ProgramArguments = [ "${home}/Applications/Glance.app/Contents/MacOS/Glance" ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
      };
      ThrottleInterval = 10;
      ProcessType = "Interactive";
    };
  };
}
