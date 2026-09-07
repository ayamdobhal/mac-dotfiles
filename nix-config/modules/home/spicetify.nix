{
  config,
  lib,
  pkgs,
  ...
}:
let
  aurora = pkgs.stdenvNoCC.mkDerivation {
    pname = "aurora-spicetify";
    version = "b50d7f8";
    src = pkgs.fetchFromGitHub {
      owner = "ayamdobhal";
      repo = "aurora";
      rev = "b50d7f82c8d220cc924861268cd5d5e147206994";
      hash = "sha256-F+eprccXQG+1ix8Uyt3FJxOqklDFLHOxpKupk+Tsw3U=";
    };
    nativeBuildInputs = [
      pkgs.typescript
      pkgs.esbuild
    ];
    buildPhase = ''
      runHook preBuild
      bash scripts/build.sh
      runHook postBuild
    '';
    installPhase = ''
      mkdir -p "$out"
      cp -r theme extensions "$out/"
    '';
  };
  applyAurora = pkgs.writeShellScriptBin "aurora-apply" ''
    exec ${pkgs.python3}/bin/python3 ${./scripts/apply-aurora.py} \
      --source ${aurora} "$@"
  '';
in
{
  # Spotify and spicetify-cli are installed by nix-darwin's Homebrew module.
  # Keep this module out of the Linux profile, which does not select Spotify.
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = [ applyAurora ];
    home.activation.applyAurora = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        ${applyAurora}/bin/aurora-apply || echo "Aurora apply failed; run aurora-apply to retry." >&2
      fi
    '';
    launchd.agents.aurora-apply = {
      enable = true;
      config = {
        ProgramArguments = [ "${applyAurora}/bin/aurora-apply" ];
        RunAtLoad = true;
        StartInterval = 300;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/aurora-apply.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/aurora-apply.log";
      };
    };
  };
}
