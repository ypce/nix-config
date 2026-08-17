{ config, lib, pkgs, ... }:

{
  # Homebrew installs Emacs (emacs-plus); see systems/homebrew.nix.
  # The config lives in its own repo. Clone it into place:
  #   git clone git@github.com:ypce/emacs.d.git ~/.emacs.d
  # This module does not symlink config files. This permits live edits
  # and use on machines without nix. This module only supplies the
  # truecolor terminfo entry and the emacs-plus build config. The mail
  # glue (nix-mu4e.el) comes from modules/email.nix.

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
  # The edaemon fish alias stays as a manual fallback.
  launchd.agents.emacs-daemon = {
    enable = true;
    config = {
      ProgramArguments = [ "/Applications/Emacs.app/Contents/MacOS/Emacs" "--fg-daemon" ];
      RunAtLoad = true;
      KeepAlive = { SuccessfulExit = false; };
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/emacs-daemon.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/emacs-daemon.log";
    };
  };

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

  home.sessionVariables = {
    COLORTERM = "truecolor";
  };

  home.file.".config/emacs-plus/build.yml".text = ''
    # icon from the community gallery
    icon: modern-purple-flat

    # Inject macOS PATH into Emacs
    inject_path: true
  '';
}
