#!/usr/bin/env bash
set -euo pipefail

# run from: $HOME/nix-config/home/emacs
SRC="$PWD"
DEST="$HOME/.emacs.d"
INIT="$SRC/init.el"

[ -d "$DEST" ] || exit 1

# patch init.el (BSD sed on macOS vs GNU sed on Linux)
if sed --version >/dev/null 2>&1; then
  sed -i 's|/etc/profiles/per-user/[^/]*/bin|/opt/homebrew/bin|g' "$INIT"
else
  sed -i '' 's|/etc/profiles/per-user/[^/]*/bin|/opt/homebrew/bin|g' "$INIT"
fi

awk '
  /^\(use-package straight/ { found=1 }
  found && /^\(use-package general/ {
    print "(use-package straight"
    print "  :custom"
    print "  (straight-use-package-by-default t)"
    print "  (straight-current-profile '\''base)"
    print "  (straight-vc-git-default-protocol '\''ssh))"
    print ""
    found=0
  }
  !found { print }
' "$INIT" > "$INIT.tmp" && mv "$INIT.tmp" "$INIT"

# symlink contents into ~/.emacs.d (skip patch-init-el.sh; don’t overwrite)
for f in *; do
  [ "$f" = "patch-init-el.sh" ] && continue
  [ -e "$DEST/$f" ] || ln -s "$SRC/$f" "$DEST/$f"
done
