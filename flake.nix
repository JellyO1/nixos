{
  description = "A simple NixOS configuration";

  inputs = {
    # NixOS official unstable repository, 25.05 is the latest stable version
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";

      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input  
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, flake-utils,... }@inputs: 
  {
    nixosConfigurations.jellyodsk = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ({
          nixpkgs.overlays = [
            (final: prev: {
              input-leap = prev.input-leap.overrideAttrs (oldAttrs: rec {
                version = "3.0.3";
                src = prev.fetchgit {
                  url = "https://github.com/input-leap/input-leap.git";
                  rev = "v${version}";
                  hash = "sha256-zSaeeMlhpWIX3y4OmZ7eHXCu1HPP7NU5HFkME/JZjuQ=";
                  fetchSubmodules = true;
                };
                patches = [];
                postFixup = ''
                  substituteInPlace $out/share/applications/io.github.input_leap.input-leap.desktop \
                    --replace "Exec=input-leap" "Exec=$out/bin/input-leap"
                '';
              });
            })
          ];
        })
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect.
        ./system/configuration.nix

        # NUR Overlay
        nur.modules.nixos.default
        
        # Home Manager
        home-manager.nixosModules.home-manager 
        {
          home-manager.backupFileExtension = "backup";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.jellyo = home/home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
      ];
    };
  };
}
