{ ... }: {
  # Dock
  system.defaults.dock = {
    autohide = true;
    mru-spaces = false;
    minimize-to-application = true;
    show-recents = false;
  };

  # Finder
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    FXEnableExtensionChangeWarning = false;
    _FXShowPosixPathInTitle = true;
    FXPreferredViewStyle = "Nlsv";
  };

  # Trackpad
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };

  # Global preferences
  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    "com.apple.swipescrolldirection" = false;
  };

  # Screenshots
  system.defaults.screencapture = {
    location = "~/Screenshots";
    type = "png";
  };
  # Login
  system.defaults.loginwindow = {
    GuestEnabled = false;
  };

}
