{ config, pkgs, lib, userConfig, ... }:

{
  imports = [
    ./common.nix
    ./modules/fish.nix
    ./modules/ghostty.nix
    ./modules/emacs.nix
  ];

  home = {
    stateVersion = "25.05";
    
    packages = with pkgs; [
      uv
      mpv
      fava
      python312Packages.beanquery
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

      # Link fonts. macOS reads ~/Library/Fonts, never ~/.local/fonts,
      # and the fonts live in private/fonts, so the old link pointed at
      # an empty directory macOS ignored. Link each file, and leave any
      # existing file alone so a manual install is never clobbered.
      if [ -d "$PRIVATE_DIR/fonts" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/Library/Fonts"
        for font in "$PRIVATE_DIR/fonts"/*; do
          [ -e "$font" ] || continue
          target="$HOME/Library/Fonts/$(basename "$font")"
          if [ ! -e "$target" ]; then
            $DRY_RUN_CMD ln -s "$font" "$target"
            echo "Linked font $(basename "$font")"
          fi
        done
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
        # --flake makes this work from any directory, not just the repo.
        nix-update = "nix flake update nixpkgs-unstable --flake $NIXCONFIG_DIR";
      };
    };
  };
}
