# ThinkPad configuration

The `thonkpad` output manages the NixOS host `thonkpad`, user `ayam`, and its Niri/NERV desktop. `nixos` is an alias for the same output. Both NixOS and Home Manager state versions remain 26.05. The checked-in hardware file is specific to this ThinkPad; do not apply it to another machine.

The Mac outputs retain their existing nixpkgs/Home Manager pins. Linux uses separately pinned `linux-*` inputs. Only the portable package core and existing dev/Neovim modules are shared. Mac system modules, Homebrew packages and AI configuration are not imported on Linux.

## Build and apply

The ThinkPad checkout lives directly at `~/.config`. Run `nrs` to detect the hostname and rebuild, or `nrs thonkpad` to select it explicitly. The old `~/projects/mac-dotfiles` path is a compatibility symlink to `~/.config`.

Use Git-backed flake references, which include tracked source files and exclude unrelated application state in this directory. Stage newly added source files before checking them. Do not use `path:~/.config`: that would include untracked application state in the Nix store.

```sh
cd ~/.config
nix flake check ./nix-config --no-write-lock-file
nix build ./nix-config#nixosConfigurations.thonkpad.config.system.build.toplevel --no-link
sudo nixos-rebuild test --flake ./nix-config#thonkpad
nrs
```

Keep the prior system generation and source backup before activation. A test activation changes the running system and Home Manager, but does not make it the boot default. Roll back a test using the recorded previous system's `bin/switch-to-configuration test`; after a persistent switch, use `sudo nixos-rebuild switch --rollback` or select the previous boot generation. Do not garbage-collect the recovery generation while testing.

NERV assets are authored under `modules/home/linux/quickshell/`. Its wallpaper is local-only at `~/.local/share/nerv/wallpaper.png`; copy your existing image there before switching. Missing wallpaper falls back to the existing background color. Launchers point to Ghostty/Neovim and this checkout. Quickshell restarts through its existing systemd user service after Home Manager updates its store-backed files.

## Applications

Ghostty + Zsh + Starship are the terminal/shell defaults. Alacritty, Fish, VS Code and OpenDesign are removed. OpenDesign's service, MCP bridge, frontend-design skill and Product Design plugin declarations are removed; independent Playwright/screenshot skills and current Codex settings remain. User-created OpenDesign data is not deleted.

Firefox, Discord, Neovim, Nemo, Loupe, Codex and Claude Code remain/install alongside the approved CLI/development tools. GCC is included for the shared Neovim Treesitter parser installer. AWS CLI, ngrok, yt-dlp, ffmpeg, Chrome, Telegram, Spotify, Bitwarden, Steam, Proton VPN, Tailscale and Spicetify are not selected for the Linux profile. An application dependency may still include a library or tool from that list in the Nix store; package removal does not delete old generations.

Zsh keeps the portable Mac Git aliases, prompt and completion setup. It does not inherit Homebrew paths, launchctl/caffeinate functions or Mac Discord socket handling. Neovim, fastfetch and Ghostty use their native tracked files in this checkout. Home Manager owns the remaining generated settings. The shared Ghostty configuration validates on Linux; Command bindings map to Super, and Mac-only settings are ignored by Ghostty on Linux. Neovim retains its read-only-config fallback for other installation layouts.

## Shortcuts

Option maps to Alt; Command maps to Super; Control stays Control. Ctrl+arrows are compositor shortcuts and therefore override the application’s normal word navigation. Niri remains a scrolling column layout, so movement differs from Yabai BSP.

| Keys | Action |
|---|---|
| Alt+F / Alt+T | Windowed fullscreen / floating |
| Ctrl+arrows | Focus left/right column or window above/below |
| Alt+Shift+arrows | Move column left/right or window up/down |
| Ctrl+Alt+Shift+H | Swap left if possible, otherwise right |
| Ctrl+Alt+U / P | Grow / shrink width by 80 logical pixels |
| Ctrl+Alt+I / O | Shrink / grow height by 80 logical pixels |
| Alt+1…9,0 | Focus stable named workspace desk-1…desk-10 |
| Alt+Shift+1…9,0 | Send window there without following focus |
| Alt+Tab | Previous workspace |
| Super+Tab | Next workspace on current output, with wrap |
| Ctrl+Alt+N | Focus trailing empty workspace on current output |
| Ctrl+Shift+R | Validate then reload Niri config |
| Super+Enter / Super+Shift+Enter | Ghostty |
| Super+D / Super+Shift+D | NERV launcher / Fuzzel fallback |
| Super+V / Super+Q | Clipboard history / close window |
| Super+F / Super+M | True fullscreen / maximize |
| Super+arrows | Existing focus aliases |
| Super+Shift+N / Space / T | Incidents / quick view / quick toggles |
| Super+Comma | Maintenance panel |
| Super+Shift+E | Existing session exit shortcut |

Volume and brightness keys are preserved. Ctrl+Alt+K is intentionally unbound: named workspaces persist, while dynamic empty workspaces disappear automatically. The Mac Ctrl+Alt+N implementation does not move the window, so neither does this one.

Workspace helpers are in `modules/home/linux/niri-shortcuts.py`. Run their tests with `python3 -B -m unittest discover -s nix-config/tests -v`. Runtime config is generated and validated by Home Manager's Niri module; do not hand-edit `~/.config/niri/config.kdl`.

Enable the repository pre-commit checks with `git config core.hooksPath .githooks`. The hook checks formatting of staged Nix files and runs the flake checks; Linux builds must still be verified on the ThinkPad.
