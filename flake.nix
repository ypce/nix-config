{
  description = "flake.nix";

  inputs = {

    # Nix-Darwin Flake Inputs 
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # homebrew
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus";
      flake = false;
    };

    # nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs:
    {
      # $ darwin-rebuild build --flake .#Seaholly
      darwinConfigurations = {
        "Seaholly" = let
          userConfig = {
            username = "vp";
            homeDirectory = "/Users/vp";
            sshKey = "vp-key";
            github = {
              username = "ypce";
              email = "service+github@paulaus.com";
            };
          };
        in inputs.nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit (inputs) self homebrew-core homebrew-cask homebrew-emacs-plus;
            inherit userConfig;
          };
          modules = [
            ./systems/mac-configuration-home.nix
            inputs.home-manager-darwin.darwinModules.home-manager
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit userConfig; };
              home-manager.users.${userConfig.username} = {
                imports = [ ./home/mac-home.nix ];
                home.username = userConfig.username;
                home.homeDirectory = userConfig.homeDirectory;
              };

              nixpkgs.overlays = [
                (final: prev: { 
                  claude-code = (import inputs.nixpkgs-unstable { 
                    system = final.system; 
                    config.allowUnfree = true; 
                  }).claude-code; 
                })
              ];
            }
          ];
        };
      };
    };
}
