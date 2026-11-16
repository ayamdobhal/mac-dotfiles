{ lib, pkgs, ... }:
let
  taps = [
    "shaunsingh/sfmono-nerd-font-ligaturized"
  ];

  brews = [ ];

  casks = [
    # browsers
    "arc"
    "zen"

    # dev tools
    # ghostty pinned to stable: tip has a regression where background-opacity
    # is not applied to new windows with macos-titlebar-style = hidden
    # (ghostty-org/ghostty#13324). Move back to ghostty@tip once fixed.
    "ghostty"
    "claude"
    "codex"
    "codex-app"

    # apps
    "bitwarden"
    "discord"
    "figma"
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

  entries = kind: names: map (name: ''${kind} "${name}"'') names;

  # `trusted: true` marks each declared third-party tap as trusted, so
  # activation never blocks on Homebrew's tap-trust prompt. Cleanup resets
  # Homebrew's trust store to exactly what the Brewfile declares.
  brewfile = pkgs.writeText "Brewfile" (
    lib.concatLines (
      map (name: ''tap "${name}", trusted: true'') taps ++ entries "brew" brews ++ entries "cask" casks
    )
  );
in
{
  # Homebrew itself is installed by hand (https://brew.sh); home-manager has no
  # Homebrew module, so this keeps the declared set in sync with `brew bundle`.
  # Anything installed with brew but not listed above is removed
  # (--force-cleanup --zap). Already-installed apps are left at their current
  # version (--no-upgrade); upgrade by hand with `brew upgrade`. Runs after
  # dotfiles are linked, and a brew failure only warns, so it can never block
  # the rest of the switch.
  home.activation.brewBundle = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -x /opt/homebrew/bin/brew ]; then
      PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
        run /opt/homebrew/bin/brew bundle --file=${brewfile} --no-upgrade --force-cleanup --zap \
        || warnEcho "brew bundle failed; fix the error above and rerun the switch."
    else
      warnEcho "Homebrew is not installed at /opt/homebrew; skipping brew bundle."
    fi
  '';
}
