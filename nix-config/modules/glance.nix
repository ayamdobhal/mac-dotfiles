{ config, ... }:
{
  # Install the locally built fork at ~/Applications/Glance.app first.
  # See glance/README.md for the Xcode build and widget installation steps.
  launchd.agents.glance = {
    enable = true;
    config = {
      ProgramArguments = [ "${config.home.homeDirectory}/Applications/Glance.app/Contents/MacOS/Glance" ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
      };
      ThrottleInterval = 10;
      ProcessType = "Interactive";
    };
  };
}
