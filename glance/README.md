# Glance

The bar uses built-in spaces and active app on the left,
and now playing, Claude/Codex usage, CPU/RAM, upload/download speeds, network,
volume, battery, weather, and date/time on the right. Click now playing for media controls or weather for the forecast.
Network speeds appear before the connection icon with `show-speed = true` under
`[widgets.default.network]`, using the built-in three-second sampler.
The center is left clear for the MacBook notch.
The system monitor includes CPU and RAM; upstream does not
currently offer a CPU-only setting. Spaces use the Nix-installed yabai binary.
The date/time keeps the existing 24-hour clock with seconds and calendar popup.

Weather uses Open-Meteo with Glance's location detection and IP fallback. It does
not yet use the custom live-location endpoint from SketchyBar. Media uses Glance's
built-in player integration; the custom Spotify API actions are not ported yet.
Remaining custom work includes app-menu switching, the Apple
menu shortcut, and the more detailed CPU/RAM popups.

The fork supports separately compiled SwiftUI widget bundles. Claude/Codex usage
is enabled on the right as `native.ai-usage`; its source and instructions live in
[glance-ai-usage](https://github.com/ayamdobhal/glance-ai-usage)
(cloned at `~/personal/glance-ai-usage`). The counter demo is
removed from the installed widgets. See `~/personal/glance/docs/native-widgets.md`
for the extension API and build instructions. Compiled bundles in `widgets/`
are ignored by git; config remains tracked here.
Glance no longer binds Command-Q; use its explicit Quit menu item to exit.

Glance reads `~/.config/glance/config.toml` if `~/.glance-config.toml` does not
exist. Changes reload automatically. A config in the home directory takes precedence.

## Installation and startup

Nix manages the Glance launch agent (`org.nixos.glance`) and yabai's 50pt bar
reservation with 4pt top padding. Glance launches at login and restarts after a
crash; its explicit Quit menu still works. SketchyBar's service, package, font,
configuration and keybinding triggers have been removed.

The app is a local Xcode build of our fork, **not a Nix-built package**.
Install it at `~/Applications/Glance.app` before activating the Nix configuration.
Source: [Glance fork](https://github.com/ayamdobhal/glance) (`~/personal/glance`). Use Xcode 26.6
with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` and the fork's
README build command. Ad-hoc sign a staged copy and replace the entire app bundle;
do not merge into an old app bundle. Rebuild the usage bundle using
[its instructions](https://github.com/ayamdobhal/glance-ai-usage#build-and-enable).

Activate on this Mac with:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix-config#ayam-magbog-work
```

On the personal Mac use `#ayam-magbog-personal`. Grant Glance Accessibility access
in System Settings if macOS requests it after replacing an ad-hoc build.
Automatic upstream update checks are disabled for this local fork.

The 50pt bar container centers 38pt widgets, leaving 6pt above and below them.
Combined with yabai's 4pt padding, the gap below widget groups is 10pt. Widget
groups have 70% dark fill and the bar background is transparent. Built-in accents
follow the macOS accent via `[appearance] accent-color = "system"`; neon-color
only controls borders and glow.

Old SketchyBar sources remain recoverable from Git history.
