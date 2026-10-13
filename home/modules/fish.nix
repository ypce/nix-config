{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    
    # Greeting and login message
    interactiveShellInit = ''
      # Custom greeting
      set fish_greeting

      # Auto-configure Tide on first run (only runs once)
      if not set -q tide_configured
        tide configure --auto --style=Lean --prompt_colors='True color' --show_time=No --lean_prompt_height='One line' --prompt_spacing=Compact --icons='Few icons' --transient=No
        set -U tide_configured yes
      end
    '';
    
    # Environment variables
    shellInit = ''
      # Colors for CLI tools
      set -gx CLICOLOR 1
      set -gx LSCOLORS ExFxCxDxBxegedabagacad

      # Prevent homebrew auto-update
      set -gx HOMEBREW_NO_AUTO_UPDATE 1
    '';
    
    # Aliases
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      q = "exit";
      
      # Safe operations
      mv = "mv -v";
      cp = "cp -rv";
      rm = "rm -i";
      mkdir = "mkdir -pv";
      
      # Git
      gst = "git status";
      gc = "git clone";
      
      # Tools
      # The Emacs daemon is a launchd agent. See modules/emacs.nix.
      # estop exits with status 0, so launchd keeps the daemon down
      # until ereload starts it again.
      #
      # A bare save-buffers-kill-emacs asks yes-or-no-p when buffers are
      # modified or processes are live. The daemon has no frame to ask
      # in, so it blocks in the minibuffer forever and stops answering
      # the socket. The t argument saves file buffers without asking,
      # and confirm-kill-processes nil skips the process question.
      ereload = "launchctl kickstart -k gui/(id -u)/org.nix-community.home.emacs-daemon";
      estop = "emacsclient -e '(let ((confirm-kill-processes nil)) (save-buffers-kill-emacs t))'";
      estatus = "launchctl print gui/(id -u)/org.nix-community.home.emacs-daemon";

      # Grep with color
      grep = "grep --color=auto";
    };
    
    # Fish-specific functions
    functions = {
      mergepdf = {
        body = ''"/System/Library/Automator/Combine PDF Pages.action/Contents/MacOS/join" $argv'';
      };

      # lazygit is gone. Open magit on the current directory instead.
      # The daemon does not share the shell working directory, so pass it.
      lg = ''
        set -x TERM xterm-emacs
        emacsclient -c -nw -a "" -e "(magit-status \"$PWD\")"
      '';

      # Navigation function - back and list
      b = ''
        cd -
        and ls -aG
      '';

      # Search previously visited directories with zoxide.
      j = ''
        zi $argv
      '';

    };
    
    # Fish plugins (optional, fish is great without them)
    plugins = [
      # Fish plugin manager support
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
          sha256 = "sha256-fl4/Pgtkojk5AE52wpGDnuLajQxHoVqyphE90IIPYFU=";
        };
      }
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "v6.2.0";
          sha256 = "sha256-1ApDjBUZ1o5UyfQijv9a3uQJ/ZuQFfpNmHiDWzoHyuw=";
        };
      }
    ];
  };
  
  # Tool integrations - Fish has these built-in!
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
  
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      search_mode = "fuzzy";
      filter_mode = "global";
    };
  };
  
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
