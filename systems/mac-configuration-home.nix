{ pkgs, lib, self, homebrew-core, homebrew-cask, homebrew-emacs-plus, userConfig, ... }:

{

  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;
  users.users.${userConfig.username}.home = userConfig.homeDirectory;

  system.activationScripts.setFishAsShell.text = ''
    dscl . -create /Users/${userConfig.username} UserShell /run/current-system/sw/bin/fish
  '';

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    
    brews = [
      { name = "emacs-plus"; }
    ];
    
    casks = [
      "ghostty"
      "wezterm"
      "chromium"
      "whatsapp"
      "appcleaner"
      "firefox"
      "discord"
      "slack"
      "proton-mail-bridge"
      "tuta-mail"
      "claude"
      "keepassxc"
      "leader-key"
      "loop"
      "museeks"
      "eqmac"
      "localsend"
      "mac-mouse-fix"
      "vnc-viewer"
    ];
    
    masApps = {
      "Yubico Authenticator" = 1497506650;
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
      # "Windows App" = 1295203466;
    };
  };
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
        NSAutomaticCapitalizationEnabled = false;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 13;
        AppleInterfaceStyle = "Dark";
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
          { app = "/Applications/Firefox.app"; }
          { app = "/Applications/Ghostty.app"; }
        ];
      };
    };

    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  nix.settings.experimental-features = "nix-command flakes";

  nix-homebrew = {
    enable = true;
    user = userConfig.username;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
    };
    mutableTaps = true;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
