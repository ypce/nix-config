{ config, pkgs, lib, userConfig, ... }:

{
  imports = [
    ./common.nix
    ./modules/fish.nix
    ./modules/ghostty.nix
    ./modules/emacs.nix
    ./modules/email.nix 
  ];

  home = {
    stateVersion = "25.05";
    
    packages = with pkgs; [
      mpv
      fava
      unstable.claude-code
      unstable.codex
      qmk
      (pkgs.writeShellScriptBin "e" ''
        export TERM=xterm-emacs
        exec emacsclient -c -nw -a "" "$@"
      '')
    ];
    
    activation.linkPrivateFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      PRIVATE_DIR="$HOME/Git/nix-config/private"

      # Link fonts
      $DRY_RUN_CMD mkdir -p $HOME/.local
      if [ -d "$PRIVATE_DIR/.local/fonts" ]; then
        $DRY_RUN_CMD rm -rf $HOME/.local/fonts
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
        nix-rebuild = "sudo darwin-rebuild switch --flake $NIXCONFIG_DIR/.#Seaholly";
      };
    };
  };
}
