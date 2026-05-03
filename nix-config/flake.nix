{
  description = "ayam's system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      lib = nixpkgs.lib;

      mkDarwin = hostname:
        let
          hostModule =
            if lib.hasInfix "work" hostname
            then ./hosts/work
            else ./hosts/personal;
        in
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            hostModule
            ./modules/darwin
            home-manager.darwinModules.home-manager
            {
              networking.hostName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.ayamdobhal = import ./modules/home;
              home-manager.extraSpecialArgs = { };
            }
          ];
        };

      mkNixos = hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/${hostname}
            ./modules/nixos
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.ayamdobhal = import ./modules/home;
              home-manager.extraSpecialArgs = { };
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
        thonkpad = mkNixos "thonkpad";
      };

      homeConfigurations."ayam@linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./modules/home ];
        extraSpecialArgs = { };
      };
    };
}
