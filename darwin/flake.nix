{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    home-manager,
    nixpkgs,
    mac-app-util,
  }: let
    username = "nico.vergara";
    system = "aarch64-darwin";
    configuration = {pkgs, ...}: {
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
      };

      system = {
        configurationRevision = self.rev or self.dirtyRev or null;
        stateVersion = 6;
        primaryUser = username;
      };

      nixpkgs = {
        config.allowUnfree = true;
        hostPlatform = system;
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Nicos-MacBook-Pro
    darwinConfigurations."Nicos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
            extraSpecialArgs = {
              inherit username;
            };
            users.${username} = import ./modules/home-manager/${username}/home.nix;
          };
        }
      ];
    };
  };
}
