{
  description = "ayam's system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    linux-nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    linux-home-manager.url = "github:nix-community/home-manager";
    linux-home-manager.inputs.nixpkgs.follows = "linux-nixpkgs";
    linux-codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    linux-codex-skills = {
      url = "github:openai/skills";
      flake = false;
    };

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sanrio-colorscripts.url = "github:ayamdobhal/sanrio-colorscripts";
    sanrio-colorscripts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      sanrio-colorscripts,
      ...
    }:
    let
      lib = nixpkgs.lib;

      mkDarwin =
        hostname:
        let
          hostModule = if lib.hasInfix "work" hostname then ./hosts/work else ./hosts/personal;
        in
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            hostModule
            ./modules/darwin
            home-manager.darwinModules.home-manager
            {
              # HostName must be fully qualified for Erlang long names (iex --name)
              networking.hostName = "${hostname}.local";
              networking.localHostName = hostname;
              networking.computerName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.ayamdobhal = import ./modules/home;
              home-manager.extraSpecialArgs = { inherit sanrio-colorscripts; };
            }
          ];
        };

      linuxInputs = {
        nixpkgs = inputs.linux-nixpkgs;
        home-manager = inputs.linux-home-manager;
        codex-cli-nix = inputs.linux-codex-cli-nix;
        codex-skills = inputs.linux-codex-skills;
      };
      thinkpad = inputs.linux-nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inputs = linuxInputs;
        };
        modules = [
          ./hosts/thonkpad
          inputs.linux-home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inputs = linuxInputs;
              inherit sanrio-colorscripts;
            };
            home-manager.users.ayam = import ./modules/home/linux/home.nix;
          }
        ];
      };
    in
    {
      darwinConfigurations = {
        "ayam-magbog-work" = mkDarwin "ayam-magbog-work";
        "ayam-magbog-personal" = mkDarwin "ayam-magbog-personal";
      };

      nixosConfigurations = {
        thonkpad = thinkpad;
        nixos = thinkpad;
      };
      checks.x86_64-linux.niri-shortcuts =
        inputs.linux-nixpkgs.legacyPackages.x86_64-linux.runCommand "niri-shortcut-tests"
          {
            nativeBuildInputs = [ inputs.linux-nixpkgs.legacyPackages.x86_64-linux.python3 ];
          }
          ''
            python3 -B -m unittest discover -s ${./.}/tests -v
            touch $out
          '';
      formatter.x86_64-linux = inputs.linux-nixpkgs.legacyPackages.x86_64-linux.nixfmt;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    };
}
