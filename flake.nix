{

  description = "System configuration flake";

  outputs = { self, nixpkgs, disko, ... }@inputs:
    let
      settings = import ./settings.nix; 

      # Select stable or unstable nixpkgs depending on settings
      pkgs = (if (settings.system.useStable) 
        then
          import inputs.nixpkgs-stable { system = settings.system.system; }
        else
          import inputs.nixpkgs-unstable { system = settings.system.system; }
      );

      lib = (if (settings.system.useStable) 
        then
          inputs.nixpkgs-stable.lib
        else
          inputs.nixpkgs-unstable.lib
      );

      # Select stable or unstable home-manager depending on settings
      home-manager = (if (settings.system.useStable)
        then
          inputs.home-manager-stable
        else
          inputs.home-manager-unstable
        );

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in {
      nixosConfigurations = {
        system = lib.nixosSystem {
          system = settings.system.system;
          modules = [
            # load configuration.nix from selected PROFILE
            (./. + "/profiles" + ("/" + settings.system.profile) + "/configuration.nix")
            # load disko config from selected PROFILE
            disko.nixosModules.disko
            (./. + "/profiles" + ("/" + settings.system.profile) + "/disc-config.nix")
          ];
          specialArgs = {
            # pass config variables from above
            inherit settings;
            inherit inputs;
            inherit lib;
          };
        };
      };

      homeConfigurations = {
        user = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            # load home.nix from selected PROFILE
            (./. + "/profiles" + ("/" + settings.system.profile) + "/home.nix")
          ];
          extraSpecialArgs = {
            # pass config variables from above
            inherit settings;
            inherit inputs;
            inherit lib;
          };
        };
      };

      diskoConfigurations = {
        disko = import (./. + "/profiles" + ("/" + settings.system.profile) + "/disc-config.nix") { inherit settings; inherit lib; };
      };

      # Programs that can be run by calling this flake
      apps = forAllSystems( system: import ./apps { inherit pkgs; } );
    };
      
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-stable";

    home-manager-stable.url = "github:nix-community/home-manager/release-23.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
  };
}
