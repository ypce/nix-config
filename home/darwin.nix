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
      # Copy files from a camera in PTP mode (the Leica M11). A PTP camera is not a disk:
      # it is not in /Volumes. gphoto2 reads it over USB.
      gphoto2
      # camera-import [DEST]: copy all files from the camera into
      # ~/Pictures/Camera/import, and, if DEST is given, rsync them to DEST.
      # DEST is a local path or host:path (for example Yarrow:/mnt/user/photography/import-m11).
      # gphoto2 writes to the local disk, not to a network share. A gphoto2 hook
      # puts each finished file in a queue, and rsync sends the queue over ssh
      # while gphoto2 reads the next files. At the end, one more rsync sends
      # anything the queue missed.
      # Files that are already in the local folder are skipped. Keep the local
      # folder, or the next import copies the files on the camera again.
      # macOS ptpcamerad claims each PTP camera and launchd restarts it, so the
      # script stops it again each second while gphoto2 runs.
      (pkgs.writeShellScriptBin "camera-import" ''
        set -euo pipefail
        rsync=${pkgs.rsync}/bin/rsync
        local_dir=$HOME/Pictures/Camera/import
        dest=''${1:-}
        mkdir -p "$local_dir"
        cd "$local_dir"
        work=$(mktemp -d)
        queue=$work/queue
        killer= sender=
        trap 'kill $killer $sender 2>/dev/null; rm -rf "$work"' EXIT

        # gphoto2 runs the hook with ACTION=download and ARGUMENT=<file> after each file.
        cat > "$work/hook" <<EOF
        #!/bin/sh
        [ "\$ACTION" = download ] && echo "\$ARGUMENT" >> "$queue"
        exit 0
        EOF
        chmod +x "$work/hook"

        if [ -n "$dest" ]; then
          ( while :; do
              if [ -s "$queue" ]; then
                mv "$queue" "$work/batch"
                $rsync -a --files-from="$work/batch" "$local_dir/" "$dest/" || true
              fi
              [ -e "$work/done" ] && break
              sleep 5
            done ) &
          sender=$!
        fi

        ( while true; do /usr/bin/pkill -9 ptpcamerad 2>/dev/null || true; sleep 1; done ) &
        killer=$!
        sleep 1
        ${pkgs.gphoto2}/bin/gphoto2 --auto-detect
        start=$SECONDS
        ${pkgs.gphoto2}/bin/gphoto2 --get-all-files --skip-existing --hook-script="$work/hook"
        kill $killer 2>/dev/null || true
        echo "camera-import: camera copy took $((SECONDS - start))s, files are in $local_dir"
        echo "camera-import: you can disconnect the camera"

        if [ -n "$dest" ]; then
          touch "$work/done"
          wait $sender || true
          $rsync -a --info=progress2 "$local_dir/" "$dest/"
          echo "camera-import: all files are in $dest, $((SECONDS - start))s in total"
        fi
      '')
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
        $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
    
        for file in "$PRIVATE_DIR/.ssh"/*; do
          [ -f "$file" ] || continue
          filename=$(basename "$file")
          target="$HOME/.ssh/$filename"
      
          # Copy private keys (not symlink) with correct permissions
          if [[ "$filename" != *.pub && "$filename" != "config"* && "$filename" != "known_hosts"* ]]; then
            if ! ${pkgs.diffutils}/bin/cmp -s "$file" "$target"; then
              $DRY_RUN_CMD cp "$file" "$target"
              echo "Copied $filename (private key)"
            fi
            $DRY_RUN_CMD chmod 600 "$target"
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
        nix-update-all = "nix flake update --flake $NIXCONFIG_DIR";
        brew-upgrade = "brew bundle";
      };
    };
  };
}
