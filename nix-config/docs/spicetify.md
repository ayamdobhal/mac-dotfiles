# Spotify with Aurora on macOS

The dotfiles install Spotify and `spicetify-cli` through nix-darwin's Homebrew
module. Home Manager builds [Aurora](https://github.com/ayamdobhal/aurora) from a
pinned Git revision, deploys its theme and extensions, and applies Spicetify.
The Linux profile does not select Spotify or this module.

- [Installation and source pin](../modules/home/spicetify.nix)
- [Deployment helper](../modules/home/scripts/apply-aurora.py)
- [Regression checks](../tests/test_aurora.py)

## Setup

Run the usual `sudo darwin-rebuild switch --flake ~/.config/nix-config#ayam-magbog-work`
(or `#ayam-magbog-personal`). On a new machine, open Spotify once so it creates
its preferences. The login agent retries every five minutes and applies Aurora
when Spotify is ready. To run immediately:

```sh
aurora-apply
```

The helper applies after an Aurora source, Spotify version or Spicetify version
change. It skips unchanged installations, serializes concurrent runs, and marks
success only after Spicetify succeeds. Spotify is never automatically restarted;
reopen it to load newly applied assets. `aurora-apply --force` reapplies manually.
Failures are retried; diagnostics are in `~/Library/Logs/aurora-apply.log`.
Spotify or Spicetify updates can still introduce compatibility changes that
require a newer Aurora revision or CLI.

## What is tracked

Track the Nix source pin, helper and documentation. Do not track
`~/.config/spicetify/`: its INI contains machine paths and generated backup
versions; Themes, Extensions and CustomApps contain installed copies.

The helper owns the Aurora selection, theme injection flags, Spotify/prefs paths,
API exposure and exact extension list. Marketplace is not enabled by this setup.
Other existing settings and Spicetify's `[Backup]` section remain local. Existing
local files are retained when removing them from Git. Before first deployment,
the previous INI, Aurora theme and extensions are saved under
`~/Library/Caches/dotfiles-aurora/before-nix/`.

## Update Aurora

Change `rev`, `hash` and the short `version` in `modules/home/spicetify.nix`, then
rebuild. Obtain the unpacked source hash for the desired full commit SHA with:

```sh
nix store prefetch-file --unpack --json https://github.com/ayamdobhal/aurora/archive/COMMIT_SHA.tar.gz
```

Aurora's TypeScript is type-checked and bundled by Nix; downloaded installer
scripts and bundled extension copies do not need to live in dotfiles.
