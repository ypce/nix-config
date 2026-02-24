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
      if test "$TERM" = "xterm-ghostty"
        set -gx TERM xterm-256color
      end

      # Default Editor
      set -gx EDITOR hx
      set -gx VISUAL hx

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
      lg = "lazygit";
      
      # Tools
      edaemon = "emacs --bg-daemon";
      
      # Grep with color
      grep = "grep --color=auto";
    };
    
    # Fish-specific functions
    functions = {
      # Navigation function - back and list
      b = ''
        cd -
        and ls -aG
      '';

      # Fuzzy directory navigation with fzf
      j = ''
        set -l dir (fd -t d -H --max-depth 5 . ~ 2>/dev/null | fzf --reverse --height 40% --prompt="Navigate to: ")
        test -n "$dir"; and cd "$dir"
      '';

      l = ''
        set date (date +"%Y-%m-%d")
        set time (date +"%H:%M")
        set daily_file $HOME/Notes/daily/$date.org
        echo "** $time $argv" >> $daily_file
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
