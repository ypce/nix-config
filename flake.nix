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

    # Determinate manages Nix itself (determinate-nixd). Pinned to major v3.
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    # and manages brew itself; the three taps below are pinned.
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
            ./systems/darwin.nix
            {
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import inputs.nixpkgs-unstable {
                    system = prev.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }
            inputs.home-manager-darwin.darwinModules.home-manager
            inputs.determinate.darwinModules.default
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit userConfig; };
              home-manager.users.${userConfig.username} = {
                imports = [ ./home/darwin.nix ];
                home.username = userConfig.username;
                home.homeDirectory = userConfig.homeDirectory;
              };
            }
          ];
        };
      };
    };
}
