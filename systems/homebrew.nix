{ config, homebrew-core, homebrew-cask, homebrew-emacs-plus, userConfig, ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    onActivation.autoUpdate = false;
    onActivation.upgrade = true;

    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [ "mas" ];  
    casks = [
      "emacs-plus-app"
      "appcleaner"
      "claude"
      "discord"
      "eqmac"
      "helium-browser"
      "ghostty"
      "keepassxc"
      "leader-key"
      "localsend"
      "loop"
      "mac-mouse-fix"
      "museeks"
      "proton-mail-bridge"
      "slack"
      "tuta-mail"
      "vnc-viewer"
      "whatsapp"
      "signal"
      "tailscale-app"
      "libreoffice"
    ];

    # Mac App Store apps install via `mas`, so they're left out.
    masApps = {
      "Yubico Authenticator" = 1497506650;
      "Windows App" = 1295203466;
    };
  };

  nix-homebrew = {
    enable = true;
    user = userConfig.username;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
    };
    mutableTaps = false;
  };
}
