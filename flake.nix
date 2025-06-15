{
  description = "A simple NixOS configuration";

  inputs = {
    # NixOS official unstable repository, 25.05 is the latest stable version
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  {
    nixosConfigurations.jellyodsk = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect.
        ./system/configuration.nix
        home-manager.nixosModules.home-manager 
        {
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
