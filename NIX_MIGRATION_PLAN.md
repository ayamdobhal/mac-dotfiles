# Brew → Nix Migration Plan

> **Goal:** Reproducible, cross-platform (macOS + Linux) system config via Nix flake + nix-darwin + home-manager. One command to bootstrap a new machine.

---

## Current State

| Layer | Current tool | Moves to |
|---|---|---|
| System packages (CLI) | Homebrew formulae | **home-manager** (cross-platform) |
| GUI apps / casks | Homebrew casks | **nix-darwin** `homebrew.casks` + nix packages where available |
| Fonts | Homebrew cask fonts | **nix packages** + brew casks for Apple-proprietary fonts |
| macOS services (yabai, skhd, sketchybar) | `brew services` | **nix-darwin** services |
| Shell (zsh + oh-my-zsh + p10k) | Manual install | **home-manager** `programs.zsh` + **starship** prompt |
| Dev runtimes (Node, Python) | nvm | **nix devShells** per-project + `direnv` |
| Dotfiles (nvim, ghostty, etc.) | Manual | **home-manager** `xdg.configFile` |
| Git config | `~/.gitconfig` | **home-manager** `programs.git` |
| macOS system preferences | Manual System Settings | **nix-darwin** `system.defaults` |

---

## Decisions log

### Packages — REMOVE entirely
| Package | Reason |
|---|---|
| `tmux` | Not using |
| `htop` | Replaced by `bottom` |
| `spotify_player` | Not needed |
| `tesseract` | Not needed |
| `wimlib` | Not needed |
| `source-highlight` | Not needed |
| `nowplaying-cli` | Sketchybar widget is API-driven now |
| `asdf` | Replaced by nix devShells + direnv |
| `mise` | Replaced by nix devShells + direnv |
| `nvm` | Replaced by nix devShells + direnv |
| `vfox` | Replaced by nix devShells + direnv |

### Packages — KEEP (move to nix)
| Package | Nix source | Notes |
|---|---|---|
| `bat` | `pkgs.bat` | cross-platform |
| `bottom` | `pkgs.bottom` | cross-platform |
| `fd` | `pkgs.fd` | cross-platform |
| `fzf` | `programs.fzf` | cross-platform, with shell integration |
| `ripgrep` | `pkgs.ripgrep` | cross-platform |
| `jq` | `pkgs.jq` | cross-platform |
| `tree` | `pkgs.tree` | cross-platform |
| `wget` | `pkgs.wget` | cross-platform |
| `lazygit` | `pkgs.lazygit` | cross-platform |
| `gh` | `pkgs.gh` | cross-platform |
| `fastfetch` | `pkgs.fastfetch` | cross-platform |
| `direnv` | `programs.direnv` | cross-platform, with nix-direnv |
| `awscli` | `pkgs.awscli2` | cross-platform |
| `neovim` | `programs.neovim` | cross-platform |
| `switchaudio-osx` | `pkgs.switchaudio-osx` | macOS only — for sketchybar volume widget |
| `bun` | `pkgs.bun` | cross-platform — replaces `~/.bun` self-install |

### Packages — neovim/sketchybar dependencies (not global tools)
These are only needed as support for nvim plugins and sketchybar, not standalone dev:
| Package | Nix source | Needed by |
|---|---|---|
| `lua` | `pkgs.lua` | sketchybar (lua config) |
| `luarocks` | `pkgs.luarocks` | neovim plugins |
| `basedpyright` | `pkgs.basedpyright` | neovim LSP |
| `rust-analyzer` | `pkgs.rust-analyzer` | neovim LSP |
| `elixir-ls` | `pkgs.elixir-ls` | neovim LSP |
| `elixir` | `pkgs.elixir` | neovim LSP (elixir-ls dep) |
| `python@3.13` | `pkgs.python313` | neovim + global fallback |

### Shell — REPLACE
| Old | New | Notes |
|---|---|---|
| oh-my-zsh | home-manager `programs.zsh` | native autosuggestions + syntax highlighting |
| powerlevel10k | **starship** | declarative TOML config, cross-platform |
| oh-my-zsh `git` plugin aliases | explicit `shellAliases` | keep the aliases you use |

### GUI Apps — KEEP (via nix-darwin casks or nix packages)
| App | Managed via | Notes |
|---|---|---|
| Arc | brew cask | |
| Bitwarden | brew cask | |
| Claude | brew cask | |
| Claude Code | brew cask | |
| Discord | brew cask | |
| Ghostty (tip) | brew cask | `ghostty@tip` — nix pkg tracks stable only |
| Google Chrome | **nix package** | `pkgs.google-chrome` |
| OrbStack | **nix package** | `pkgs.orbstack` |
| ProtonVPN | brew cask | |
| Raycast | **nix package** | `pkgs.raycast` |
| SF Symbols | brew cask | Apple proprietary |
| Spotify | brew cask | managed by spicetify-nix |
| Steam | brew cask | |
| Tailscale | brew cask | |
| Telegram | brew cask | |
| Zen | brew cask | |

### GUI Apps — DELETE during Phase 0
```bash
# Run these before starting migration
sudo rm -rf /Applications/AirServer.app
sudo rm -rf /Applications/Cursor.app
sudo rm -rf /Applications/Dia.app
sudo rm -rf /Applications/Firefox.app
sudo rm -rf /Applications/Freeways.app
sudo rm -rf "/Applications/GoPro Quik.app"
sudo rm -rf /Applications/iMovie.app
sudo rm -rf "/Applications/Lunar Client.app"
sudo rm -rf /Applications/Obsidian.app
sudo rm -rf "/Applications/Porting Kit.app"
sudo rm -rf /Applications/Postman.app
sudo rm -rf /Applications/Stremio.app
sudo rm -rf /Applications/Termius.app
sudo rm -rf "/Applications/Visual Studio Code.app"
sudo rm -rf /Applications/WhatsApp.app
sudo rm -rf /Applications/Whisky.app
```

### GUI Apps — KEEP (unmanaged — App Store / Apple)
| App | Notes |
|---|---|
| Final Cut Pro | App Store |
| Logic Pro | App Store |
| GarageBand | Apple built-in |
| Numbers | Apple built-in |
| Pages | Apple built-in |
| Keynote | Apple built-in |
| Blackmagic Proxy Generator Lite | Comes with DaVinci Resolve |

---

## Architecture

```
flake.nix                          ← single entry point
├── darwinConfigurations
│   ├── "work"                     ← current MacBook (this machine)
│   └── "personal"                 ← second MacBook (M3 Pro)
├── homeConfigurations
│   └── "ayam@linux"               ← future Linux use
└── shared home-manager modules    ← cross-platform core
```

**Key design decisions:**
- **Flake-based** — reproducible, lockfile-pinned, no channels
- **nix-darwin wraps home-manager** as a module on macOS — `darwin-rebuild switch` does everything in one shot
- **Standalone home-manager** on Linux — `home-manager switch` only
- **Existing config files stay as-is** — nvim lua, sketchybar lua, ghostty config, etc. are symlinked by home-manager via `xdg.configFile`, not rewritten in nix
- **Modular** — one nix file per concern, easy to toggle features per host
- **GUI apps use brew casks via nix-darwin** — the accepted pattern on macOS. nix-darwin declaratively manages what brew installs
- **3 apps as nix packages** — Chrome, OrbStack, Raycast are available natively in nixpkgs
- **Spicetify via `spicetify-nix` flake** — manages Spotify theming declaratively
- **Starship prompt** — replaces p10k, configured via TOML, cross-platform
- **macOS system preferences via nix-darwin** — dock, finder, keyboard, trackpad, etc.

---

## Directory Structure

```
~/.config/
├── nix-config/
│   ├── flake.nix                  # entry point
│   ├── flake.lock                 # pinned versions
│   │
│   ├── hosts/
│   │   ├── work/
│   │   │   └── default.nix        # nix-darwin config for work MacBook
│   │   └── personal/
│   │       └── default.nix        # nix-darwin config for personal MacBook
│   │
│   ├── modules/
│   │   ├── darwin/                # macOS-only modules
│   │   │   ├── default.nix        # imports all darwin modules
│   │   │   ├── system.nix         # macOS system preferences (dock, finder, keyboard, etc.)
│   │   │   ├── homebrew.nix       # declarative cask management
│   │   │   ├── yabai.nix          # yabai service + config
│   │   │   ├── skhd.nix           # skhd service + config
│   │   │   └── sketchybar.nix     # sketchybar service
│   │   │
│   │   └── home/                  # cross-platform home-manager modules
│   │       ├── default.nix        # imports all home modules
│   │       ├── shell.nix          # zsh, aliases, starship, plugins
│   │       ├── packages.nix       # CLI tools (bat, fd, ripgrep, etc.)
│   │       ├── git.nix            # git config, signing, aliases
│   │       ├── neovim.nix         # neovim + LSPs + config symlink
│   │       ├── ghostty.nix        # symlinks ghostty config
│   │       ├── dev.nix            # dev runtimes, direnv integration
│   │       ├── fastfetch.nix      # symlinks fastfetch config
│   │       └── spicetify.nix      # spicetify-nix config
│   │
│   └── overlays/                  # custom package overrides (if needed)
│       └── default.nix
│
├── nvim/                          # UNCHANGED
├── ghostty/                       # UNCHANGED
├── sketchybar/                    # UNCHANGED
├── yabai/                         # UNCHANGED
├── skhd/                          # UNCHANGED
├── fastfetch/                     # UNCHANGED
├── ccstatusline/                  # UNCHANGED — symlinked
├── spicetify/                     # UNCHANGED — referenced by spicetify-nix
└── ...
```

---

## Phase 0: Preparation

### 0.1 — Snapshot current state
- [ ] `brew bundle dump --file=~/.config/Brewfile` — safety net for rollback
- [ ] Commit all current dotfile changes to git
- [ ] Create a `feat/nix-migration` branch

### 0.2 — Delete unused apps
- [ ] Run the app deletion commands from the "GUI Apps — DELETE" section above

### 0.3 — Verify nix
- [x] Nix is installed (Determinate Nix 3.0.0 — flakes enabled)
- [ ] Verify: `nix flake show nixpkgs` lists outputs

---

## Phase 1: Scaffold the flake + nix-darwin

### 1.1 — Create `flake.nix`

```nix
{
  description = "ayam's system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, spicetify-nix, ... }: {
    darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/work
        ./modules/darwin
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ayamdobhal = import ./modules/home;
          home-manager.extraSpecialArgs = { inherit spicetify-nix; };
        }
      ];
    };

    darwinConfigurations."personal" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/personal
        ./modules/darwin
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ayamdobhal = import ./modules/home;
          home-manager.extraSpecialArgs = { inherit spicetify-nix; };
        }
      ];
    };

    # Future Linux support
    homeConfigurations."ayam@linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./modules/home ];
      extraSpecialArgs = { inherit spicetify-nix; };
    };
  };
}
```

### 1.2 — Minimal nix-darwin host config
- [ ] Create `hosts/work/default.nix`:
  - `nixpkgs.hostPlatform = "aarch64-darwin"`
  - `system.stateVersion = 6`
  - `users.users.ayamdobhal.home = "/Users/ayamdobhal"`
- [ ] First build: `darwin-rebuild switch --flake .#work`
- [ ] **Verify nothing breaks**

### 1.3 — Minimal home-manager config
- [ ] Create `modules/home/default.nix`:
  - `home.stateVersion = "25.05"`
  - `home.username = "ayamdobhal"`
  - `home.homeDirectory = "/Users/ayamdobhal"`
- [ ] Rebuild and verify

---

## Phase 2: Migrate CLI packages

### 2.1 — Core CLI tools

`modules/home/packages.nix`:
```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # core utils
    bat
    bottom
    fd
    jq
    ripgrep
    tree
    wget
    lazygit
    gh
    fastfetch
    awscli2
    bun

    # neovim/sketchybar deps
    lua
    luarocks
    basedpyright
    rust-analyzer
    elixir-ls
    elixir
    python313
  ];
}
```

### 2.2 — Neovim

`modules/home/neovim.nix`:
```nix
{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # symlink existing lua config
  xdg.configFile."nvim" = {
    source = ../../../nvim;
    recursive = true;
  };
}
```

### 2.3 — macOS-only packages

In `hosts/work/default.nix` (and `hosts/personal/`):
```nix
environment.systemPackages = with pkgs; [
  switchaudio-osx
];
```

### 2.4 — Verify
- [ ] `darwin-rebuild switch --flake .#work`
- [ ] Spot-check: `bat --version`, `rg --version`, `nvim --version`, `bun --version`
- [ ] **Do NOT uninstall brew versions yet** — both coexist

---

## Phase 3: Shell config

### 3.1 — Zsh via home-manager

`modules/home/shell.nix`:
```nix
{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      lgt = "lazygit";
      python = "python3";
      claude = "claude --dangerously-skip-permissions";

      # git aliases (from oh-my-zsh git plugin — keep the ones you use)
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gb = "git branch";
      gc = "git commit";
      gcam = "git commit --all --message";
      gcb = "git checkout -b";
      gcm = "git checkout main";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git pull";
      glog = "git log --oneline --decorate --graph";
      gp = "git push";
      grb = "git rebase";
      gst = "git status";
      gsw = "git switch";
    };

    initExtra = ''
      # Discord IPC
      ln -sf "$TMPDIR/discord-ipc-0" /tmp/discord-ipc-0 2>/dev/null

      # Work navigation helper
      z() { cd "$HOME/work/iv-pro/iv-pro-$1"; }
    '';
  };

  # starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # 2-line lean prompt matching your p10k layout
      format = ''
        $os$directory$git_branch$git_status$fill$cmd_duration$direnv$nix_shell
        $character
      '';
      right_format = "";

      os = {
        disabled = false;
        style = "bold white";
      };
      os.symbols = {
        Macos = " ";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        style = "bold green";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
      };

      fill = {
        symbol = " ";
      };

      cmd_duration = {
        style = "bold yellow";
        min_time = 2000;
        format = "[$duration]($style) ";
      };

      direnv = {
        disabled = false;
        style = "bold blue";
      };

      nix_shell = {
        disabled = false;
        style = "bold purple";
        format = "[$symbol$state]($style) ";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  # fzf with shell integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # direnv + nix-direnv for fast dev shells
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
```

### 3.2 — Verify
- [ ] Rebuild
- [ ] New shell: check starship prompt renders (2-line, os icon + dir + git left, duration right)
- [ ] Check aliases: `gst`, `gp`, `lgt`, etc.
- [ ] Check autosuggestions + syntax highlighting
- [ ] Check `fzf` keybindings (Ctrl+R, Ctrl+T)
- [ ] Check `direnv` hooks in

### 3.3 — Clean up after verification
- [ ] Back up `~/.zshrc` → `~/.zshrc.bak`
- [ ] Back up `~/.p10k.zsh` → `~/.p10k.zsh.bak`
- [ ] Delete `~/.oh-my-zsh` directory
- [ ] Delete `~/.nvm` directory

---

## Phase 4: Dotfile symlinks + git

### 4.1 — Symlink configs

```nix
# modules/home/ghostty.nix
{ ... }: {
  xdg.configFile."ghostty/config".source = ../../../ghostty/config;
}

# modules/home/fastfetch.nix
{ ... }: {
  xdg.configFile."fastfetch" = {
    source = ../../../fastfetch;
    recursive = true;
  };
}
```

Also symlink: `ccstatusline/`, `spicetify/`, `htop/` (if keeping config).

### 4.2 — Git config

`modules/home/git.nix`:
```nix
{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Ayam Dobhal";
    userEmail = "me@iamdobhal.dev";
    lfs.enable = true;
    signing = {
      key = "~/.ssh/id_rsa.pub";
      signByDefault = true;
      format = "ssh";
    };
    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
```

### 4.3 — Verify
- [ ] `git config --global user.name` → "Ayam Dobhal"
- [ ] `nvim` opens, plugins load, LSPs connect
- [ ] `cat -l ~/.config/ghostty/config` shows symlink to nix store

---

## Phase 5: macOS services — yabai, skhd, sketchybar

### 5.1 — yabai

`modules/darwin/yabai.nix`:
```nix
{ pkgs, ... }: {
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
    extraConfig = builtins.readFile ../../../yabai/yabairc;
  };
}
```

Note: remove the `sudo yabai --load-sa` line from yabairc — nix-darwin handles that.

### 5.2 — skhd

`modules/darwin/skhd.nix`:
```nix
{ pkgs, ... }: {
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = builtins.readFile ../../../skhd/skhdrc;
  };
}
```

### 5.3 — sketchybar

`modules/darwin/sketchybar.nix`:
```nix
{ pkgs, ... }: {
  services.sketchybar = {
    enable = true;
    package = pkgs.sketchybar;
  };

  # sketchybar reads config from ~/.config/sketchybar/
  # this is already in the dotfiles repo — home-manager symlinks it
}
```

In `modules/home/default.nix`, add sketchybar config symlink:
```nix
xdg.configFile."sketchybar" = {
  source = ../../../sketchybar;
  recursive = true;
};
```

### 5.4 — Switch over
- [ ] `brew services stop yabai && brew services stop skhd && brew services stop sketchybar`
- [ ] `darwin-rebuild switch --flake .#work`
- [ ] Verify: `launchctl list | grep -E "yabai|skhd|sketchybar"`
- [ ] Test: window tiling, hotkeys, status bar widgets

---

## Phase 6: macOS system preferences

`modules/darwin/system.nix`:
```nix
{ ... }: {
  # Dock
  system.defaults.dock = {
    autohide = true;               # adjust to your preference
    mru-spaces = false;            # don't rearrange spaces based on recent use
    minimize-to-application = true;
    show-recents = false;
    # tilesize = 48;               # icon size — set to your preference
  };

  # Finder
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    FHIDeExtensionChangeWarning = false;
    _FXShowPosixPathInTitle = true;
    FXPreferredViewStyle = "Nlsv";  # list view
  };

  # Trackpad
  system.defaults.trackpad = {
    Clicking = true;               # tap to click
    TrackpadRightClick = true;     # two-finger right click
  };

  # Keyboard
  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
    InitialKeyRepeat = 15;         # shorter delay before key repeat
    KeyRepeat = 2;                 # faster key repeat
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    "com.apple.swipescrolldirection" = true;  # natural scrolling
  };

  # Screenshots
  system.defaults.screencapture = {
    location = "~/Screenshots";    # adjust to your preference
    type = "png";
  };

  # Login window
  system.defaults.loginwindow = {
    GuestEnabled = false;
  };
}
```

> **Note:** Review and adjust each setting to match your current preferences before building. Run `defaults read` commands to check current values if unsure.

---

## Phase 7: GUI apps + fonts

### 7.1 — Declarative cask management

`modules/darwin/homebrew.nix`:
```nix
{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";          # remove anything not declared
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
      "orbstack"                 # fallback if nix pkg has issues
      "claude"
      "claude-code"

      # apps
      "bitwarden"
      "discord"
      "spotify"
      "telegram"
      "steam"
      "protonvpn"
      "tailscale"

      # system
      "raycast"
      "sf-symbols"

      # fonts (Apple proprietary — can't use nix)
      "font-sf-mono"
      "font-sf-pro"
      "font-sf-mono-nerd-font-ligaturized"
    ];
  };
}
```

### 7.2 — Nix-native fonts

In `modules/home/packages.nix`:
```nix
home.packages = with pkgs; [
  # ... other packages
  nerd-fonts.hack
];
```

### 7.3 — Nix-native GUI apps

In `hosts/work/default.nix`:
```nix
environment.systemPackages = with pkgs; [
  google-chrome
  orbstack
  raycast
  switchaudio-osx
];
```

> If the nix packages for Chrome/OrbStack/Raycast cause issues on macOS (some nix GUI pkgs can be flaky on darwin), fall back to brew casks — just move them to the casks list.

### 7.4 — Spicetify

`modules/home/spicetify.nix`:
```nix
{ spicetify-nix, pkgs, ... }: {
  imports = [ spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;
    # theme and extensions — configure based on your current spicetify config
    # check ~/.config/spicetify/ for current theme/extension choices
  };
}
```

---

## Phase 8: Dev runtimes

### 8.1 — Per-project dev shells (primary approach)

Example for a Node project:
```nix
# project-root/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = [ pkgs.nodejs_22 pkgs.nodePackages.pnpm ];
      };
    };
}

# project-root/.envrc
use flake
```

`cd` into project → direnv activates → correct Node available. No nvm.

### 8.2 — Global fallback runtimes

`modules/home/dev.nix`:
```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs_22       # for quick one-off scripts outside projects
    python313       # global python (also needed by nvim)
    bun             # already in packages.nix but listed here for clarity
  ];
}
```

### 8.3 — Verify
- [ ] `cd` into a work project with a `flake.nix` + `.envrc` → direnv loads → `node --version` correct
- [ ] Outside any project: `node --version`, `python3 --version` work (global fallbacks)

---

## Phase 9: Second MacBook setup

### 9.1 — Create host config

- [ ] Create `hosts/personal/default.nix` — copy from `hosts/work/`, adjust hostname
- [ ] Add `darwinConfigurations."personal"` to `flake.nix` (already in template above)

### 9.2 — Bootstrap script

`~/.config/nix-config/bootstrap.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Bootstrapping system..."

# 1. Install Determinate Nix
if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install
  echo "==> Nix installed. Restart your shell and re-run this script."
  exit 0
fi

# 2. Install Homebrew (needed for casks)
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 3. Clone dotfiles
if [ ! -d "$HOME/.config/.git" ]; then
  echo "==> Cloning dotfiles..."
  git clone https://github.com/YOUR_USERNAME/dotfiles.git "$HOME/.config"
fi

# 4. Build and switch
HOST="${1:-$(scutil --get LocalHostName)}"
echo "==> Building configuration for host: $HOST"
cd "$HOME/.config/nix-config"
darwin-rebuild switch --flake ".#$HOST"

echo "==> Done! Restart your terminal."
```

### 9.3 — On the second MacBook
- [ ] Partially disable SIP (for yabai scripting addition)
- [ ] Run bootstrap script: `bash <(curl -sL YOUR_RAW_BOOTSTRAP_URL) personal`
- [ ] Or manually: install nix, clone repo, `darwin-rebuild switch --flake .#personal`
- [ ] Verify everything matches primary machine

---

## Phase 10: Cleanup — phase out brew formulae

### 10.1 — Verify everything works via nix
- [ ] Every CLI tool works
- [ ] Shell correct (starship prompt, aliases, autosuggestions, syntax highlighting)
- [ ] yabai, skhd, sketchybar services running
- [ ] Git config correct
- [ ] Neovim + LSPs work
- [ ] Spicetify applied to Spotify
- [ ] Dev shells work in at least one project
- [ ] macOS system preferences applied

### 10.2 — Uninstall brew formulae
```bash
# Nix now provides all CLI tools — remove brew versions
brew list --formula | xargs brew uninstall --ignore-dependencies

# Keep brew itself — nix-darwin uses it for casks
```

### 10.3 — Clean up old files
- [ ] Delete `~/.oh-my-zsh/`
- [ ] Delete `~/.nvm/`
- [ ] Delete `~/.bun/` (nix provides bun now)
- [ ] Back up then delete `~/.zshrc.bak`, `~/.p10k.zsh.bak`
- [ ] Back up then delete `~/.gitconfig` (home-manager owns it)
- [ ] Grep all configs for `/opt/homebrew` and update any hardcoded paths

---

## Phase 11: Linux support (future)

### What's already cross-platform
All `modules/home/` modules work on Linux:
- packages, shell (zsh + starship), git, neovim, ghostty, fastfetch, dev runtimes, direnv

### What's macOS-only
`modules/darwin/` won't be imported on Linux:
- yabai, skhd, sketchybar
- homebrew.nix
- system.nix (macOS preferences)

### Linux activation
Already defined in `flake.nix`. On a Linux box:
```bash
home-manager switch --flake .#ayam@linux
```

---

## Rollback plan

If anything goes wrong:

1. **Brew is untouched until Phase 10** — fall back to brew versions anytime
2. **Brewfile saved in Phase 0** — `brew bundle install --file=Brewfile` restores everything
3. **nix-darwin generations** — `darwin-rebuild --list-generations` and switch back
4. **home-manager generations** — `home-manager generations` and activate previous
5. **Git branch** — all work on `feat/nix-migration`, main untouched

---

## Things to watch out for

1. **`/opt/homebrew` hardcoded paths** — sketchybar lua, yabairc, skhdrc may reference `/opt/homebrew/bin/`. Grep all configs and update to bare command names (they'll be in PATH via nix)
2. **yabai scripting addition** — requires partially disabled SIP on both MacBooks
3. **Ghostty @tip** — nix package tracks stable. Keep as brew cask to stay on tip builds
4. **Bun** — using `pkgs.bun` from nix, so remove `~/.bun` and the `BUN_INSTALL` PATH exports
5. **Spicetify** — `spicetify-nix` manages the Spotify patching. Check your current theme/extensions in `~/.config/spicetify/` and replicate in nix config
6. **Home-manager owns `~/.zshrc`** — back up before first rebuild. Manual edits get overwritten on rebuild
7. **PATH ordering** — nix binaries in `/run/current-system/sw/bin` and `~/.nix-profile/bin` should come before `/opt/homebrew/bin`. nix-darwin handles this but verify
8. **`darwin-rebuild` requires hostname match** — the flake config name must match what you pass. Use `scutil --get LocalHostName` to check
9. **Git aliases** — the `shellAliases` in Phase 3 are a starting set from oh-my-zsh's git plugin. Review and keep only the ones you actually use, add any missing ones
