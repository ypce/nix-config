# nix-config
macOS nix-darwin + home-manager + flakes config.

## Install
```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# 2. Clone
git clone git@github.com:ypce/nix-config.git ~/Git/nix-config
# 3. Bootstrap
nix run nix-darwin -- switch --flake .#Seaholly
```

## Daily use
```bash
n                      # rebuild + export artifacts
nix flake update && n  # update + rebuild
```

## Maintenance
```bash
nix-collect-garbage --delete-older-than 30d
nix-store --optimise
darwin-rebuild --rollback  # if something breaks
```

## Non-Nix machines
The `artifacts/` folder contains generated, Nix-reference-free versions of all config files, kept in sync automatically on every rebuild.
```bash
# Clone the repo
git clone git@github.com:ypce/nix-config.git ~/Git/nix-config

# Symlink configs to correct locations
~/Git/nix-config/artifacts/install.sh

# To update, just pull
git pull
```

## Gotchas
- `git add` new files before rebuilding (flakes only see tracked files)
- home-manager won't overwrite existing dotfiles
- most rebuild time is Homebrew syncing
