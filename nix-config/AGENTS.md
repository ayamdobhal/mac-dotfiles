# Configuration maintenance

Keep machine services, boot, users and hardware in hosts/ and modules/nixos/.
Keep user packages, dotfiles and NERV configuration in modules/home/linux/.
Preserve the two Mac outputs and their input revisions when editing Linux.
Do not change system.stateVersion or home.stateVersion during routine work.

Start graphical-session applications through app2unit in the Niri config.
Keep app2unit installed and preserve the Quickshell graphical-session unit.

Run checks from the repository root, including the dir query so sibling assets
are visible in the flake source:

    nix flake check 'path:.?dir=nix-config' --no-write-lock-file
    nix build 'path:.?dir=nix-config#nixosConfigurations.thonkpad.config.system.build.toplevel' --no-link

Validate on Linux before activation. Record the current system generation and
retain the existing source as a rollback baseline. Test before switching.
Use Conventional Commits at major checkpoints. Do not bypass .githooks/pre-commit;
install it with git config core.hooksPath .githooks. Review lock changes rather
than performing a blanket input update.
