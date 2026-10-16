{
  config,
  lib,
  pkgs,
  ...
}:
let
  revision = "b7b464edb0d89ffdaba499aae291bf700b93a3b6";
  runtime = "${config.home.homeDirectory}/Library/Application Support/ListeningLab/current";
  lab = pkgs.writeShellScriptBin "listening-lab" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.git
        pkgs.nodejs
        pkgs.python3
        pkgs.openssh
      ]
    }:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/usr/local/bin
    exec ${pkgs.python3}/bin/python3 ${./scripts/listening-lab.py} --revision ${revision} "$@"
  '';
  service = pkgs.writeShellScript "listening-lab-service" ''
    if [ ! -f ${lib.escapeShellArg "${runtime}/helper/server.cjs"} ]; then exit 0; fi
    cd ${lib.escapeShellArg runtime}
    exec ${pkgs.nodejs}/bin/node helper/server.cjs
  '';
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = [ lab ];
    home.activation.setupListeningLab = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        ${lab}/bin/listening-lab setup || echo "Listening Lab setup failed; run listening-lab setup to retry." >&2
      fi
    '';
    launchd.agents.listening-lab = {
      enable = true;
      config = {
        ProgramArguments = [ "${service}" ];
        RunAtLoad = true;
        KeepAlive.SuccessfulExit = false;
        ThrottleInterval = 30;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/listening-lab.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/listening-lab.log";
      };
    };
  };
}
