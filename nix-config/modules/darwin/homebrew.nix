{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
    };
    taps = [
      "shaunsingh/sfmono-nerd-font-ligaturized"
    ];
    casks = [
      # browsers
      "arc"
      "zen"

      # dev tools
      "ghostty@tip"
      "claude"
      "claude-code"

      # apps
      "bitwarden"
      "discord"
      "spotify"
      "telegram"
      "steam"
      "protonvpn"
      "tailscale-app"

      # system
      "raycast"
      "sf-symbols"
      "orbstack"
      "google-chrome"

      # fonts (Apple proprietary)
      "font-sf-mono"
      "font-sf-pro"
      "font-sf-mono-nerd-font-ligaturized"
    ];
  };
}
