{ ... }:
let
  trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };
in
{
  # User-domain macOS preferences. Some only take effect after a re-login or
  # `killall Dock` / `killall Finder`.
  targets.darwin.defaults = {
    "com.apple.dock" = {
      autohide = true;
      mru-spaces = false;
      minimize-to-application = true;
      show-recents = false;
    };

    "com.apple.finder" = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
      FXPreferredViewStyle = "Nlsv";
    };

    # Built-in and Bluetooth trackpads read separate domains.
    "com.apple.AppleMultitouchTrackpad" = trackpad;
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = trackpad;

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      "com.apple.swipescrolldirection" = false;
    };

    "com.apple.screencapture" = {
      location = "~/Screenshots";
      type = "png";
    };
  };
}
