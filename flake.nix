{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager/b7697abe89967839b273a863a3805345ea54ab56";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      username = "nicoevergara";
      system = "x86_64-linux";
      unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
      unfree-pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unfree-pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        jay = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/jay
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              home-manager.extraSpecialArgs = {
                inherit unfree-pkgs;
                inherit unstable-pkgs;
                inherit unfree-pkgs-unstable;
                inherit username;
              };
            }
          ];
        };
        calibre = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/calibre
          ];
        };
      };
    };
}
