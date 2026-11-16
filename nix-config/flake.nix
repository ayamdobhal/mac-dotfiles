{
  description = "ayam's mac home config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sanrio-colorscripts.url = "github:ayamdobhal/sanrio-colorscripts";
    sanrio-colorscripts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sanrio-colorscripts,
      ...
    }:
    let
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./overlays) ];
      };

      # Every Mac gets the same ./home.nix. A host contributes a package list
      # and nothing else (hosts/*.nix are `pkgs: [ ... ]`), so the machines
      # cannot drift apart in any other way.
      mkHome =
        hostPackages:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit sanrio-colorscripts; };
          modules = [
            ./home.nix
            { home.packages = hostPackages pkgs; }
          ];
        };
    in
    {
      # `home-manager switch --flake .` picks "$USER@$(hostname -s)".
      homeConfigurations = {
        "ayamdobhal@ayam-magbog-work" = mkHome (import ./hosts/work.nix);
        "ayamdobhal@ayam-magbog-personal" = mkHome (import ./hosts/personal.nix);
      };

      checks.${system}.aurora =
        pkgs.runCommand "aurora-tests"
          {
            nativeBuildInputs = [ pkgs.python3 ];
          }
          ''
            python3 -B -m unittest discover -s ${./.}/tests -v
            touch $out
          '';

      formatter.${system} = pkgs.nixfmt;
    };
}
