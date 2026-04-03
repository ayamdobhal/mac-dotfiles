# dotfiles

Reproducible macOS (and Linux) system config managed with **Nix** — nix-darwin + home-manager + flakes.

One command to set up a new machine:

```bash
darwin-rebuild switch --flake ~/.config/nix-config#work
```

![sketchybar](sketchybar/demo.png)

## Architecture

```
nix-config/
├── flake.nix               # entry point
├── hosts/
│   ├── work/               # work MacBook config
│   └── personal/           # personal MacBook config
└── modules/
    ├── darwin/              # macOS-only (yabai, skhd, sketchybar, system prefs, brew casks)
    └── home/                # cross-platform (shell, packages, git, neovim, dev runtimes)
```

- **nix-darwin** manages macOS system config, services, and brew casks
- **home-manager** manages CLI tools, shell, git, and dotfile symlinks
- **Existing configs** (nvim, sketchybar, ghostty, etc.) stay as native files — not rewritten in Nix

## What's inside

| Directory | Description |
|-----------|-------------|
| **nix-config** | Nix flake — system and home-manager config |
| **nvim** | Neovim setup with Lazy plugin manager |
| **ghostty** | Ghostty terminal config |
| **sketchybar** | Custom status bar in Lua — workspaces, media, widgets (CPU, RAM, weather, battery, Spotify, Claude usage) |
| **yabai** | Tiling window manager config |
| **skhd** | Hotkey daemon keybindings (pairs with yabai) |
| **fastfetch** | System info fetch with custom logo |
| **ccstatusline** | Claude Code status line settings |
| **spicetify** | Spotify theming via spicetify-nix |

## Managed by Nix

| Layer | Tool |
|-------|------|
| CLI tools | home-manager (`bat`, `fd`, `rg`, `lazygit`, `gh`, `neovim`, etc.) |
| Shell | home-manager (zsh + starship + fzf + direnv) |
| Git | home-manager (`programs.git`) |
| Dev runtimes | nix devShells + direnv (per-project Node, Python, etc.) |
| GUI apps | nix-darwin homebrew module (Arc, Ghostty, Discord, Spotify, etc.) |
| macOS services | nix-darwin (yabai, skhd, sketchybar) |
| macOS preferences | nix-darwin (dock, finder, keyboard, trackpad) |
| Fonts | nix + brew casks |
| Spotify theming | spicetify-nix |

## Setup on a new Mac

1. Install [Determinate Nix](https://install.determinate.systems/nix)
2. Clone this repo to `~/.config`
3. Run `darwin-rebuild switch --flake ~/.config/nix-config#work` (or `#personal`)
4. Partially disable SIP for yabai scripting addition ([guide](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection))
