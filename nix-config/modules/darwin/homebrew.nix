{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      extraFlags = [ "--force-cleanup" ];
      autoUpdate = true;
    };
    taps = [
      "shaunsingh/sfmono-nerd-font-ligaturized"
      "xmqywx/codeisland"
      "codeptor/tap"
    ];
    brews = [
      "spicetify-cli"
      "mausam"
    ];
    casks = [
      # browsers
      "arc"
      "zen"

      # dev tools
      "ghostty@tip"
      "claude"
      "codex"
      "codex-app"

      # apps
      "bitwarden"
      "xmqywx/codeisland/codeisland"
      "discord"
      "spotify"
      "telegram"
      "whatsapp"
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
