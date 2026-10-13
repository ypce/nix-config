{ config, pkgs, lib, self, userConfig, ... }:

let
  # Collect at most once a week. The daemon asks far more often than
  # that, so the stamp, not the schedule, decides when work happens.
  nix-gc = pkgs.writeShellScript "nix-gc" ''
    stamp=/var/lib/nix-gc/last-run
    week=$((7 * 24 * 60 * 60))
    now=$(date +%s)

    # A missing, empty or damaged stamp reads as 0, which collects now
    # and writes a good stamp. Never let a bad stamp stop collection.
    last=$(cat "$stamp" 2>/dev/null)
    case "$last" in
      "" | *[!0-9]*) last=0 ;;
    esac

    if [ $((now - last)) -lt $week ]; then
      exit 0
    fi

    echo "=== nix-gc $(date) ==="
    /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 30d || exit $?
    mkdir -p "$(dirname "$stamp")" || exit $?
    date +%s > "$stamp"
  '';
in
{
 imports = [ ./homebrew.nix ];

  environment.shells = [ pkgs.fish "/run/current-system/sw/bin/fish" ];
  programs.fish.enable = true;
  users.users.${userConfig.username}.home = userConfig.homeDirectory;

  # Ghostty asks for two families. AeonikMono is a manual install from
  # private/fonts. CaskaydiaCove is the italic face, so nix supplies it.
  # fira-code, jetbrains-mono and hack were installed here and never
  # referenced by anything.
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
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

      CustomUserPreferences = {
        NSGlobalDomain."com.apple.mouse.scaling" = -1.0;   # disable mouse acceleration (linear tracking)
      };

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

  # determinateNix.enable turns off nix-darwin's Nix management, which
  # takes nix.gc with it: setting nix.gc.automatic here is accepted and
  # then silently ignored. Run the collector from launchd instead.
  # Root, because deleting system profile generations needs it.
  #
  # A StartCalendarInterval would be wrong here. launchd runs a missed
  # calendar job after sleep, but not after a shutdown, so a machine
  # that is off at the scheduled hour never collects. Measure elapsed
  # time instead: check at boot and once a day, and collect when a week
  # of real time has passed, whenever the machine happens to be on.
  launchd.daemons.nix-gc = {
    serviceConfig = {
      ProgramArguments = [ "${nix-gc}" ];
      RunAtLoad = true;
      StartInterval = 86400;
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
      LowPriorityIO = true;
      Nice = 10;
    };
  };

  # nix-darwin restarts the Dock with `killall -qu vp Dock` after it
  # writes com.apple.dock defaults. launchd respawns the process, but it
  # comes back without the wallpaper and needs a manual kickstart. Stop
  # and start the agent through launchd instead, which restores both.
  system.activationScripts.postActivation.text = ''
    echo "restarting the Dock agent..." >&2
    launchctl kickstart -k "gui/$(id -u ${userConfig.username})/com.apple.Dock.agent" || true
  '';

  security.pam.services.sudo_local.touchIdAuth = true;
  determinateNix.enable = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
  
