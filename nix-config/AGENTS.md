# Configuration maintenance

This flake is Mac-only and uses standalone Home Manager; there is no nix-darwin
or NixOS configuration. Nothing here may require root at switch time. The one
root-owned piece, the yabai scripting addition, is handled by the
`yabai-sa-setup` command defined in modules/yabai.nix.

Both Macs share home.nix and everything under modules/. hosts/*.nix are plain
package lists (`pkgs: [ ... ]`); do not add any other per-host difference.
Do not change home.stateVersion during routine work.

Run checks from the repository root, using the Git flake so only tracked files enter the source
(the checkout can contain private application state under ~/.config):

    nix flake check ./nix-config --no-write-lock-file
    nix build './nix-config#homeConfigurations."ayamdobhal@ayam-magbog-work".activationPackage' --no-link

Build before switching. Use Conventional Commits at major checkpoints. Do not
bypass .githooks/pre-commit; install it with git config core.hooksPath .githooks.
Review lock changes rather than performing a blanket input update.
