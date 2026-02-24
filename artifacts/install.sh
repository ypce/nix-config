#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/map.sh"

REPO_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
EXPORT_DIR="$REPO_DIR/artifacts"

for pattern in "${ARTIFACT_SOURCES[@]}"; do
  for src in "$EXPORT_DIR"/$pattern; do
    [ -f "$src" ] || continue
    relative="${src#"$EXPORT_DIR"/}"
    dest="$HOME/$relative"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      mv "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
      echo "Backed up: $dest"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "Linked: $dest"
  done
done
