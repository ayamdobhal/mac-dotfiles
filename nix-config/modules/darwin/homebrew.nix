{ config, ... }: {
  # Trust every declared third-party tap before `brew bundle` runs, so
  # activation never blocks on Homebrew's tap-trust prompt. Regenerated from
  # homebrew.taps on each switch; preActivation runs before the bundle phase.
  # Written as a real (writable) file so `brew trust/untrust` still work by hand.
  system.activationScripts.preActivation.text = ''
    install -d -o ayamdobhal -g staff /Users/ayamdobhal/.homebrew
    cat > /Users/ayamdobhal/.homebrew/trust.json <<'TRUST_EOF'
    ${builtins.toJSON { trustedtaps = map (t: t.name) config.homebrew.taps; }}
    TRUST_EOF
    chown ayamdobhal:staff /Users/ayamdobhal/.homebrew/trust.json
  '';

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      extraFlags = [ "--force-cleanup" ];
      autoUpdate = true;
    };
    taps = [
      "shaunsingh/sfmono-nerd-font-ligaturized"
      "codeptor/tap"
    ];
    brews = [
      "spicetify-cli"
      "codeptor/tap/mausam"
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
