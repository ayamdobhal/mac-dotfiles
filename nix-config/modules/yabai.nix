{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Upstream release binary instead of the nixpkgs source build. nixpkgs links
  # the scripting addition with -Wl,-no_uuid, and dyld on macOS 26 refuses to
  # dlopen a dylib without LC_UUID ("missing LC_UUID load command"), so that
  # payload never loads into Dock: --load-sa "succeeds" at injecting and every
  # space operation still fails. Drop this override once nixpkgs stops doing
  # that (check: otool -l on the installed payload shows LC_UUID).
  yabai = pkgs.yabai.overrideAttrs (_: rec {
    version = "7.1.25";
    src = pkgs.fetchzip {
      url = "https://github.com/asmvik/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
      hash = "sha256-hGZLoY5zZjtVtjMbYQ4VHqAuAD835Tdfq6YX122/9Ik=";
    };
    nativeBuildInputs = [ pkgs.installShellFiles ];
    buildInputs = [ ];
    postPatch = "";
    preBuild = "";
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp ./bin/yabai $out/bin/yabai
      installManPage ./doc/yabai.1
      runHook postInstall
    '';
  });

  yabaiBin = "${yabai}/bin/yabai";
  sudoersFile = "/etc/sudoers.d/yabai";
  saStamp = "/Library/ScriptingAdditions/.yabai-sa-package";

  # Everything about the scripting addition (SA) that needs root. home-manager
  # runs unprivileged, so this is a separate command: run `sudo yabai-sa-setup`
  # once per machine and again whenever the yabai package changes (activation
  # warns when it is stale). It
  #   1. lets admins run exactly this yabai build's `--load-sa` without a
  #      password (sudo matches the literal store path and its sha256, so the
  #      rule has to be rewritten for every new build), which is what yabairc
  #      uses to (re)load the SA at login and after Dock restarts;
  #   2. reinstalls, patches and loads the SA into Dock.
  yabai-sa-setup = pkgs.writeShellApplication {
    name = "yabai-sa-setup";
    text = ''
      if [ "$(id -u)" -ne 0 ]; then
        echo "yabai-sa-setup must run as root: sudo yabai-sa-setup" >&2
        exit 1
      fi

      YABAI="${yabaiBin}"
      LOADER="/Library/ScriptingAdditions/yabai.osax/Contents/MacOS/loader"
      SA_STAMP="${saStamp}"

      # sudoers rule, validated before it is put in place.
      rule_tmp=$(mktemp)
      trap 'rm -f "$rule_tmp"' EXIT
      digest=$(/usr/bin/shasum -a 256 "$YABAI" | cut -d ' ' -f 1)
      printf '%%admin ALL=(root) NOPASSWD: sha256:%s %s --load-sa\n' "$digest" "$YABAI" > "$rule_tmp"
      /usr/sbin/visudo -cf "$rule_tmp" > /dev/null
      # World-readable (still root-owned) so activation can check it is current.
      /usr/bin/install -o root -g wheel -m 0444 "$rule_tmp" "${sudoersFile}"
      echo "Installed ${sudoersFile}"

      # PAC ABI v1 -> v0 patch for the SA loader (yabai 7.1.17 + Sequoia/Tahoe
      # bug). The offsets are the arm64e cpusubtype byte in the fat header and in
      # the arm64e slice of the *installed* universal loader (yabai codesigns it
      # on install, which moves the slice to 0x10000). Both must change together
      # or the loader is "bad CPU type". Only touch a byte that really is 0x81:
      # written blind into a thin loader this clobbers its first load command.
      patch_pac_byte() {
        [ "$(od -An -tx1 -j "$1" -N 1 "$LOADER" 2>/dev/null | tr -d ' \n')" = "81" ] || return 1
        printf '\x80' | dd of="$LOADER" bs=1 seek="$1" count=1 conv=notrunc 2>/dev/null
      }
      patch_loader() {
        [ -f "$LOADER" ] || return 0
        patched=0
        if patch_pac_byte 32; then patched=1; fi
        if patch_pac_byte 65547; then patched=1; fi
        if [ "$patched" = 1 ]; then
          codesign -f -s - "$LOADER" 2>/dev/null
          echo "Patched yabai scripting addition PAC ABI"
        fi
        return 0
      }
      loader_id() { /usr/bin/stat -f %i "$LOADER" 2>/dev/null || echo none; }

      # yabai reinstalls the SA only when its version string changes, so files
      # from another build of the same version (or damaged ones) stay forever.
      # Wipe them whenever the package that installed them is not this one.
      if [ "$(cat "$SA_STAMP" 2>/dev/null)" != "$YABAI" ]; then
        "$YABAI" --uninstall-sa 2>/dev/null || true
      fi

      # --load-sa exits 0 both when it injected the payload and when it merely
      # (re)installed the files and restarted Dock, in which case nothing is
      # loaded yet. A changed loader inode means "installed"; go again once Dock
      # is back. Re-patch right after an install so the dock_did_restart signal
      # does not race us with an unpatched loader.
      sa_loaded=0
      for _ in 1 2 3 4 5 6 7 8; do
        patch_loader
        before=$(loader_id)
        if "$YABAI" --load-sa 2>/dev/null && [ "$before" != none ] && [ "$before" = "$(loader_id)" ]; then
          sa_loaded=1
          break
        fi
        patch_loader
        sleep 2
      done
      if [ "$sa_loaded" = 1 ]; then
        printf '%s' "$YABAI" > "$SA_STAMP"
        echo "Loaded yabai scripting addition into Dock"
      else
        echo "warning: yabai scripting addition failed to load into Dock" >&2
        exit 1
      fi
    '';
  };
in
{
  home.packages = [
    yabai
    yabai-sa-setup
  ];

  # Configuration is not managed here: yabai runs ~/.config/yabai/yabairc
  # straight from the dotfiles checkout. Restart to apply an edit
  # (ctrl + shift - r in skhdrc).
  launchd.agents.yabai = {
    enable = true;
    config = {
      ProgramArguments = [
        yabaiBin
        "-c"
        "${config.xdg.configHome}/yabai/yabairc"
      ];
      # yabairc calls `yabai` and `sudo`; the store path comes first so
      # `command -v yabai` there resolves to the exact binary sudoers allows.
      EnvironmentVariables.PATH = builtins.concatStringsSep ":" [
        "${yabai}/bin"
        "${config.home.profileDirectory}/bin"
        "/opt/homebrew/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/yabai/yabai.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/yabai/yabai.err.log";
    };
  };

  # The root-owned half cannot be applied from here; say so when it is stale.
  home.activation.checkYabaiScriptingAddition = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ "$(cat ${saStamp} 2>/dev/null)" != "${yabaiBin}" ] \
      || ! grep -qF "${yabaiBin} --load-sa" ${sudoersFile} 2>/dev/null; then
      warnEcho "yabai scripting addition is not set up for this yabai build. Run: sudo yabai-sa-setup"
    fi
  '';
}
