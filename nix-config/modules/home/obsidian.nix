{ config, lib, pkgs, ... }:

let
  vaultPath = "${config.home.homeDirectory}/obsidian-vault/ayam";
  dotfilesLink = "${config.home.homeDirectory}/.config/obsidian-vault";
  vaultRemote = "git@github.com:ayamdobhal/obsidian-vault.git";
  git = "${pkgs.git}/bin/git";
in
{
  home.activation.ensureObsidianVault =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      vault_dir=${lib.escapeShellArg vaultPath}
      dotfiles_link=${lib.escapeShellArg dotfilesLink}
      vault_remote=${lib.escapeShellArg vaultRemote}

      mkdir -p "$(dirname "$vault_dir")"

      if [ -d "$vault_dir/.git" ]; then
        current_remote="$(${git} -C "$vault_dir" remote get-url origin 2>/dev/null || true)"
        if [ -z "$current_remote" ]; then
          ${git} -C "$vault_dir" remote add origin "$vault_remote"
        elif [ "$current_remote" != "$vault_remote" ]; then
          echo "Obsidian vault remote differs from expected remote: $current_remote" >&2
        fi
      elif [ -e "$vault_dir" ]; then
        if [ -z "$(find "$vault_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
          rmdir "$vault_dir"
          if ! ${git} clone "$vault_remote" "$vault_dir"; then
            echo "Could not clone Obsidian vault from $vault_remote" >&2
          fi
        else
          echo "Obsidian vault path exists but is not a git checkout: $vault_dir" >&2
        fi
      else
        if ! ${git} clone "$vault_remote" "$vault_dir"; then
          echo "Could not clone Obsidian vault from $vault_remote" >&2
        fi
      fi

      if [ -d "$vault_dir" ]; then
        mkdir -p "$(dirname "$dotfiles_link")"
        if [ -L "$dotfiles_link" ]; then
          current_link="$(readlink "$dotfiles_link")"
          if [ "$current_link" != "$vault_dir" ]; then
            ln -sfn "$vault_dir" "$dotfiles_link"
          fi
        elif [ -e "$dotfiles_link" ]; then
          echo "Not replacing existing non-symlink path: $dotfiles_link" >&2
        else
          ln -s "$vault_dir" "$dotfiles_link"
        fi
      fi
    '';
}
