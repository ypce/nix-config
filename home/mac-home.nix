{ config, pkgs, lib, userConfig, ... }:

{
  imports = [
    ./common.nix
    ./modules/aria2-personal.nix
    ./modules/emacs-personal.nix
    ./modules/browser.nix
  ];

  home = {
    stateVersion = "25.05";
    
    packages = with pkgs; [
      # :START_TODO:
      # https://github.com/xenodium/agent-shell
      # https://www.reddit.com/r/emacs/comments/1qecqbs/experimenting_with_a_faster_tramp_backend_using/
      # https://revpdf.com/download.html
      # Mjoyufull/setrixtuix 
      # :END_TODO:
      mpv
      fava
      claude-code
      qmk
      (pkgs.writeShellScriptBin "e" ''
        exec emacsclient -c -nw -a "" "$@"
      '')
    ];
    
    file.".claude/settings.json".text = ''
      {
        "env": {
          "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
          "ANTHROPIC_AUTH_TOKEN": "",
          "ANTHROPIC_TIMEOUT_MS": "600000",
          "ANTHROPIC_MODEL": "deepseek-chat",
          "ANTHROPIC_SMALL_FAST_MODEL": "deepseek-chat",
          "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
        }
      }
    '';

    activation.linkPrivateFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      PRIVATE_DIR="$HOME/Git/nix-config/private"
  
      # Link fonts
      $DRY_RUN_CMD mkdir -p $HOME/.local
      $DRY_RUN_CMD rm -rf $HOME/.local/fonts
      if [ -d "$PRIVATE_DIR/.local/fonts" ]; then
        $DRY_RUN_CMD ln -sf "$PRIVATE_DIR/.local/fonts" $HOME/.local/fonts
        echo "Linked private fonts"
      fi
  
      # Link/copy SSH files
      if [ -d "$PRIVATE_DIR/.ssh" ]; then
        $DRY_RUN_CMD mkdir -p $HOME/.ssh
    
        for file in "$PRIVATE_DIR/.ssh"/*; do
          filename=$(basename "$file")
          target="$HOME/.ssh/$filename"
      
          # Copy private keys (not symlink) with correct permissions
          if [[ "$filename" != *.pub && "$filename" != "config"* && "$filename" != "known_hosts"* ]]; then
            $DRY_RUN_CMD cp "$file" "$target"
            $DRY_RUN_CMD chmod 600 "$target"
            echo "Copied $filename (private key)"
          else
            # Symlink everything else (config files, public keys)
            $DRY_RUN_CMD ln -sf "$file" "$target"
            echo "Linked $filename"
          fi
        done
      fi
    '';
  };

  programs = {
    home-manager.enable = true;
    
    fish = {
      shellAliases = {
        n = "sudo darwin-rebuild switch --flake $NIXCONFIG_DIR/.#Seaholly";
        so = "rclone bisync ~/Org/ yarrow-sftp:/ --check-access --conflict-resolve newer --conflict-loser num --conflict-suffix 'conflict-{DateOnly}' --create-empty-src-dirs --resilient --recover --max-lock 2m -MvP";
      };
    };
  };
}
