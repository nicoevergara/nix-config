{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager/b7697abe89967839b273a863a3805345ea54ab56";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      plasma-manager,
      nix-darwin,
      mac-app-util,
      nix-homebrew,
      ...
    }:
    let
      username = "nicoevergara";
      darwinSystem = "aarch64-darwin";
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      unstable-pkgs = forAllSystems (
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "spotify"
              "zoom"
              "claude-code"
            ];
        }
      );
      darwin-configuration = _: {
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
          hostPlatform = darwinSystem;
        };
      };
    in
    {
      formatter = forAllSystems (system: nixpkgs-unstable.legacyPackages.${system}.nixfmt);
      nixosConfigurations = {
        jay = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/jay
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
                extraSpecialArgs = {
                  inherit username;
                  isDarwin = false;
                  stable-pkgs = nixpkgs.legacyPackages."x86_64-linux";
                  unstable-pkgs = unstable-pkgs."x86_64-linux";
                };
              };
            }
          ];
        };
      };
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Nicos-MacBook-Pro
      darwinConfigurations."Nicos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          darwin-configuration
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
            };
            homebrew = {
              enable = true;
              casks = [
                "ghostty"
                "chromium"
              ];
            };
          }
          {
            # Let Determinate Nix handle Nix config
            nix.enable = false;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
              extraSpecialArgs = {
                inherit username;
                isDarwin = true;
                stable-pkgs = nixpkgs.legacyPackages.${darwinSystem};
                unstable-pkgs = unstable-pkgs.${darwinSystem};
              };
              users.${username} = import ./users/${username}/home-manager/home.nix;
            };
          }
        ];
      };
    };
}
