# dotfiles

Reproducible macOS setup managed with **Nix** — standalone home-manager + flakes. No nix-darwin, so a rebuild never needs sudo:

```bash
nrs    # home-manager switch --flake ~/.config/nix-config
```

## Architecture

```
nix-config/
├── flake.nix               # entry point: one homeConfiguration per Mac
├── home.nix                # shared by both Macs
├── hosts/
│   ├── work.nix            # work-only package list
│   └── personal.nix        # personal-only package list
└── modules/                # shell, packages, git, neovim, macOS defaults,
                            # brew casks, yabai, skhd, glance, caffeinate, ...
```

- **home-manager** manages CLI tools, shell, git, dotfile symlinks, launch agents, macOS preferences and brew casks
- **Both Macs share one config.** A host file is only a package list, so nothing else can differ between them
- **Layering:** another flake can add modules on top with `lib.mkHome { host = "work"; modules = [ ... ]; }` (see `flake.nix`); `dotfiles.rebuild` points `nrs` at that flake. `~/.config/private/` is ignored for this purpose
- **Existing configs** (nvim, glance, ghostty, yabai, skhd, etc.) stay as native files — not rewritten in Nix, and edits apply without a rebuild

## What's inside

| Directory | Description |
|-----------|-------------|
| **nix-config** | Nix flake — home-manager config |
| **nvim** | Neovim setup with Lazy plugin manager |
| **ghostty** | Ghostty terminal config |
| **glance** | Native SwiftUI status bar — spaces, media, system widgets and a separate Claude/Codex usage bundle |
| **yabai** | Tiling window manager config |
| **skhd** | Hotkey daemon keybindings (pairs with yabai) |
| **fastfetch** | System info fetch with custom logo |
| **ccstatusline** | Claude Code status line settings |
| **[Aurora setup](nix-config/docs/spicetify.md)** | Nix-built Aurora theme and automatic Spicetify application |

## Glance status bar

[Our Glance fork](https://github.com/ayamdobhal/glance) provides the native SwiftUI
bar and custom-widget SDK. The separate
[Claude/Codex usage widget](https://github.com/ayamdobhal/glance-ai-usage) displays
local token activity and usage limits without adding provider code to Glance.

- [Bar configuration](glance/config.toml) and [setup guide](glance/README.md)
- [Nix launch agent](nix-config/modules/glance.nix) and [yabai spacing](yabai/yabairc)
- [Widget build instructions](https://github.com/ayamdobhal/glance-ai-usage#build-and-enable)

Spaces and the active app sit on the left; the center stays clear for the notch.
The right side is media → Claude/Codex → CPU/RAM → upload/download → network →
sound → battery → weather → date/time. The bar background is transparent, with
dark widget groups and the macOS accent color.

Nix manages startup; `yabairc` reserves the bar's space. Glance itself and its widget bundle are built
locally with Xcode; install them before activating Nix. SketchyBar has been
removed; its old setup is available in Git history.

## Managed by Nix

| Layer | Tool |
|-------|------|
| CLI tools | home-manager (`bat`, `fd`, `rg`, `lazygit`, `gh`, `neovim`, etc.) |
| Shell | home-manager (zsh + starship + fzf + direnv) |
| Git | home-manager (`programs.git`) |
| Dev runtimes | nix devShells + direnv (per-project Node, Python, etc.) |
| GUI apps | Homebrew casks, declared in `modules/homebrew.nix` and applied with `brew bundle` on every switch (Arc, Ghostty, Discord, Spotify, etc.) |
| macOS services | home-manager launch agents (yabai, skhd, glance, caffeinate) |
| macOS preferences | home-manager `targets.darwin.defaults` (dock, finder, keyboard, trackpad) |
| Fonts | nix + brew casks |
| Spotify theming | Pinned [Aurora](https://github.com/ayamdobhal/aurora) build + Home Manager deployment; Spicetify CLI via Homebrew |

## Spotify and Aurora

The [Aurora setup](nix-config/docs/spicetify.md) installs Spotify and Spicetify,
builds the theme and extensions from a pinned [Aurora](https://github.com/ayamdobhal/aurora)
commit, and applies them automatically. Open Spotify once on a new machine;
`aurora-apply` can trigger deployment immediately. A login agent also checks for
version changes every five minutes without restarting Spotify.

Spicetify's INI, backup metadata, Marketplace files and installed theme/extension
copies stay local and are ignored by Git.

## Setup on a new Mac

1. Install [Determinate Nix](https://install.determinate.systems/nix) and [Homebrew](https://brew.sh)
2. Clone this repo to `~/.config`
3. Name the machine `ayam-magbog-work` or `ayam-magbog-personal`; the flake picks the config by host name. The `.local` suffix on HostName is needed for Erlang long names (`iex --name`):
   ```bash
   sudo scutil --set LocalHostName ayam-magbog-work
   sudo scutil --set ComputerName ayam-magbog-work
   sudo scutil --set HostName ayam-magbog-work.local
   ```
4. First switch (afterwards just `nrs`):
   ```bash
   nix run home-manager -- switch --flake ~/.config/nix-config -b backup
   ```
5. Partially disable SIP for yabai scripting addition ([guide](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection))
6. Run `sudo yabai-sa-setup`. It installs the sudoers rule and loads the scripting addition; it is the only step that needs root, and is needed again only when the yabai package changes (the switch prints a reminder)
