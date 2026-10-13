{ config, lib, pkgs, homebrew-core, homebrew-cask, homebrew-emacs-plus, userConfig, ... }:
let
  home = config.home-manager.users.${userConfig.username};
  emacsConfig = home.home.file.".config/emacs-plus/build.yml";
  emacsConfigHash = builtins.hashString "sha256" emacsConfig.text;
  emacsStamp = "${home.xdg.stateHome}/emacs-plus-build-yml.hash";
  asUser = "sudo -u ${lib.escapeShellArg userConfig.username} --set-home";
in
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;
    global.brewfile = true;

    # Supply the config before Home Manager creates its links.
    extraConfig = ''
      ENV["HOMEBREW_EMACS_PLUS_BUILD_CONFIG"] = "${emacsConfig.source}"
    '';

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
      "museeks"
      "rawtherapee"
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

  # Record the config after a successful first installation.
  system.activationScripts.homebrew.text = lib.mkMerge [
    (lib.mkBefore ''
      emacs_first_install=0
      if ! ${asUser} /opt/homebrew/bin/brew list --cask emacs-plus-app >/dev/null 2>&1; then
        emacs_first_install=1
      fi
    '')
    (lib.mkAfter ''
      if [ "$emacs_first_install" = 1 ] &&
         ${asUser} /opt/homebrew/bin/brew list --cask emacs-plus-app >/dev/null 2>&1; then
        ${asUser} ${pkgs.coreutils}/bin/install -Dm644 \
          ${pkgs.writeText "emacs-plus-build-yml.hash" "${emacsConfigHash}\n"} \
          ${lib.escapeShellArg emacsStamp}
      fi
    '')
  ];

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
