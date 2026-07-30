{ config, pkgs, lib, self, userConfig, ... }:
{
 imports = [ ./homebrew.nix ];

  environment.shells = [ pkgs.fish "/run/current-system/sw/bin/fish" ];
  programs.fish.enable = true;
  users.users.${userConfig.username}.home = userConfig.homeDirectory;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  system = {
    primaryUser = userConfig.username;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;   # natural scroll OFF (Windows-style)
        NSAutomaticCapitalizationEnabled = false;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 13;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        KeyRepeat = 2;
      };

      trackpad.Clicking = true;

      controlcenter = {
        BatteryShowPercentage = true;
      };

      screencapture = {
        location = "${userConfig.homeDirectory}/Pictures/";
        type = "png";
      };

      finder = {
        NewWindowTarget = "Other";
        NewWindowTargetPath = "file:/${userConfig.homeDirectory}/";
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
      };

      WindowManager.EnableStandardClickToShowDesktop = false;

      dock = {
        show-recents = false;
        autohide-time-modifier = 0.2;
        autohide = false;
        show-process-indicators = true;
        launchanim = false;
        tilesize = 36;
        magnification = true;
        largesize = 48;
        persistent-apps = [
          { app = "/Applications/Helium.app"; }
          { app = "/Applications/Ghostty.app"; }
        ];
      };
    };

    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  determinateNix.enable = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
  
