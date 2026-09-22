{ config, lib, pkgs, ... }:

let
  # Consumed twice: written to ~/.config/emacs-plus/build.yml, and hashed
  # so activation can tell when the cask must re-read it.
  buildYml = ''
    # icon from the community gallery. liquid-glass ships a Tahoe
    # Assets.car, so macOS 26 renders it natively.
    icon: liquid-glass

    # Inject macOS PATH into Emacs
    inject_path: true
  '';
in
{
  # Homebrew installs Emacs (emacs-plus); see systems/homebrew.nix.
  # The config lives in its own repo. Clone it into place:
  #   git clone git@github.com:ypce/emacs.d.git ~/.emacs.d
  # This module does not symlink config files. This permits live edits
  # and use on machines without nix. This module only supplies the
  # truecolor terminfo entry and the emacs-plus build config.

  # Bootstrap the config on fresh machines: clone ypce/emacs.d if
  # ~/.emacs.d does not exist yet. An existing clone is never touched,
  # so live edits stay safe.
  home.activation.cloneEmacsConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -e "$HOME/.emacs.d" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone git@github.com:ypce/emacs.d.git "$HOME/.emacs.d"
    fi
  '';

  # Run the Emacs daemon as a launchd login service. brew services can
  # not manage emacs-plus-app because it is a cask. Clients attach with
  # `emacsclient -a ''`. KeepAlive.SuccessfulExit = false restarts the
  # daemon after a crash but lets kill-emacs (exit 0) actually stop it.
  # launchd throttles the CPU of background agents by default.
  # ProcessType = Interactive stops that throttling.
  launchd.agents.emacs-daemon = {
    enable = true;
    config = {
      ProgramArguments = [ "/Applications/Emacs.app/Contents/MacOS/Emacs" "--fg-daemon" ];
      RunAtLoad = true;
      KeepAlive = { SuccessfulExit = false; };
      ProcessType = "Interactive";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/emacs-daemon.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/emacs-daemon.log";
    };
  };

  # home-manager reloads an agent only when the plist changes. A daemon
  # stopped by kill-emacs therefore stays down until the next login.
  # kickstart without -k starts a stopped daemon and ignores a running
  # one. A rebuild never drops live buffers.
  home.activation.startEmacsDaemon = lib.hm.dag.entryAfter ["setupLaunchAgents"] ''
    $DRY_RUN_CMD /bin/launchctl kickstart "gui/$UID/org.nix-community.home.emacs-daemon" || true
  '';

  # Use macOS /usr/bin/tic - nixpkgs tic uses hex paths (78/), macOS ncurses
  # uses letter paths (x/), so the nix derivation approach silently produces
  # a terminfo file emacs-plus never finds.
  home.activation.installEmacsTerminfo = lib.hm.dag.entryAfter ["writeBoundary"] ''
    tmpfile=$(mktemp)
    cat > "$tmpfile" << 'TERMINFO'
xterm-emacs|xterm-256color extended with Emacs 24-bit direct-color,
    use=xterm-256color,
    setf24=\E[38;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
    setb24=\E[48;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
TERMINFO
    $DRY_RUN_CMD /usr/bin/tic -x "$tmpfile"
    rm "$tmpfile"
  '';

  # helix set EDITOR through programs.helix.defaultEditor. Emacs owns it
  # now. The -a '' fallback starts a daemon if launchd does not have one.
  home.sessionVariables = {
    COLORTERM = "truecolor";
    EDITOR = "emacsclient -c -nw -a ''";
    VISUAL = "emacsclient -c -nw -a ''";
  };

  home.file.".config/emacs-plus/build.yml".text = buildYml;

  # The seam between nix and Homebrew. nix owns build.yml, but the
  # emacs-plus-app cask reads it in its postflight, and `brew bundle`
  # skips an already-installed cask. An edit here therefore has no
  # effect until something forces a reinstall.
  #
  # Keep a stamp of the content hash and reinstall the cask when it
  # changes. This runs after linkGeneration, which is what writes
  # build.yml, and before startEmacsDaemon.
  #
  # The icon lives in the app bundle, so a running daemon does not
  # block the change and is not restarted here.
  home.activation.applyEmacsBuildConfig =
    lib.hm.dag.entryBetween [ "startEmacsDaemon" ] [ "linkGeneration" ] ''
      brew=/opt/homebrew/bin/brew
      stamp="${config.xdg.stateHome}/emacs-plus-build-yml.hash"
      want="${builtins.hashString "sha256" buildYml}"

      # Write through a temp file. GNU install refuses to read a process
      # substitution ("skipping file '/dev/fd/63', as it was replaced
      # while being copied"), and a plain shell redirect would fire even
      # under --dry-run, because the shell redirects before DRY_RUN_CMD
      # can suppress anything.
      write_stamp() {
        local tmp
        tmp=$(mktemp)
        echo "$want" > "$tmp"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm644 "$tmp" "$stamp"
        rm -f "$tmp"
      }

      if [ ! -x "$brew" ]; then
        :
      elif [ "$(cat "$stamp" 2>/dev/null || true)" = "$want" ]; then
        :
      elif ! "$brew" list --cask emacs-plus-app >/dev/null 2>&1; then
        # Not installed yet. The homebrew activation installs it below,
        # and its postflight reads the build.yml we just wrote.
        write_stamp
      else
        echo "emacs-plus build.yml changed, reinstalling the cask..."
        if $DRY_RUN_CMD "$brew" reinstall --cask emacs-plus-app; then
          write_stamp
          echo "Run 'ereload' to move the daemon onto the new binary."
        else
          echo "emacs-plus-app reinstall failed. build.yml is unapplied." >&2
        fi
      fi
    '';
}
