{ config, lib, pkgs, ... }:

{
  # Emacs is installed via Homebrew (emacs-plus) - see
  # systems/mac-configuration-home.nix. This module only manages the config
  # files + a truecolor terminfo entry; it does NOT install Emacs, so it won't
  # collide with the brew build. Daemon is started via the `edaemon` fish alias.

  home.file.".emacs.d/init.el".source = ../emacs/init.el;
  home.file.".emacs.d/early-init.el".source = ../emacs/early-init.el;
  home.file.".emacs.d/programming.el".source = ../emacs/programming.el;
  home.file.".emacs.d/dracula-pro-pro-theme.el".source = ../emacs/themes/dracula-pro-pro-theme.el;

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
