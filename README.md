# dotfiles

Reproducible macOS (and Linux) system config managed with **Nix** — nix-darwin + home-manager + flakes.

For a Mac:

```bash
darwin-rebuild switch --flake ~/.config/nix-config#ayam-magbog-work
```

For the ThinkPad (Niri + NERV, Ghostty + Zsh + Starship), see [the Linux setup and shortcut guide](nix-config/docs/thinkpad/README.md).

## Architecture

```
nix-config/
├── flake.nix               # entry point
├── hosts/
│   ├── work/               # work MacBook config
│   └── personal/           # personal MacBook config
└── modules/
    ├── darwin/              # macOS-only (yabai, skhd, glance, system prefs, brew casks)
    └── home/                # cross-platform (shell, packages, git, neovim, dev runtimes)
```

- **nix-darwin** manages macOS system config, services, and brew casks
- **home-manager** manages CLI tools, shell, git, and dotfile symlinks
- **Existing configs** (nvim, glance, ghostty, etc.) stay as native files — not rewritten in Nix

## What's inside

| Directory | Description |
|-----------|-------------|
| **nix-config** | Nix flake — system and home-manager config |
| **nvim** | Neovim setup with Lazy plugin manager |
| **ghostty** | Ghostty terminal config |
| **glance** | Native SwiftUI status bar — spaces, media, system widgets and a separate Claude/Codex usage bundle |
| **yabai** | Tiling window manager config |
| **skhd** | Hotkey daemon keybindings (pairs with yabai) |
| **fastfetch** | System info fetch with custom logo |
| **ccstatusline** | Claude Code status line settings |
| **spicetify** | Spotify theming via spicetify-nix |

## Glance status bar

[Our Glance fork](https://github.com/ayamdobhal/glance) provides the native SwiftUI
bar and custom-widget SDK. The separate
[Claude/Codex usage widget](https://github.com/ayamdobhal/glance-ai-usage) displays
local token activity and usage limits without adding provider code to Glance.

- [Bar configuration](glance/config.toml) and [setup guide](glance/README.md)
- [Nix launch agent](nix-config/modules/darwin/glance.nix) and [yabai spacing](nix-config/modules/darwin/yabai.nix)
- [Widget build instructions](https://github.com/ayamdobhal/glance-ai-usage#build-and-enable)

Spaces and the active app sit on the left; the center stays clear for the notch.
The right side is media → Claude/Codex → CPU/RAM → upload/download → network →
sound → battery → weather → date/time. The bar background is transparent, with
dark widget groups and the macOS accent color.

Nix manages startup and spacing. Glance itself and its widget bundle are built
locally with Xcode; install them before activating Nix. SketchyBar has been
removed; its old setup is available in Git history.

## Managed by Nix

| Layer | Tool |
|-------|------|
| CLI tools | home-manager (`bat`, `fd`, `rg`, `lazygit`, `gh`, `neovim`, etc.) |
| Shell | home-manager (zsh + starship + fzf + direnv) |
| Git | home-manager (`programs.git`) |
| Dev runtimes | nix devShells + direnv (per-project Node, Python, etc.) |
| GUI apps | nix-darwin homebrew module (Arc, Ghostty, Discord, Spotify, etc.) |
| macOS services | nix-darwin (yabai, skhd, glance) |
| macOS preferences | nix-darwin (dock, finder, keyboard, trackpad) |
| Fonts | nix + brew casks |
| Spotify theming | spicetify-nix |

## Setup on a new Mac

1. Install [Determinate Nix](https://install.determinate.systems/nix)
2. Clone this repo to `~/.config`
3. Run `darwin-rebuild switch --flake ~/.config/nix-config#ayam-magbog-work` (or `#ayam-magbog-personal`)
4. Partially disable SIP for yabai scripting addition ([guide](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection))
