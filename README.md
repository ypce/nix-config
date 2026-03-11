# nix-config
macOS nix-darwin + home-manager + flakes config.

## Install
```bash
# install nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# clone
git clone git@github.com:ypce/nix-config.git ~/Git/nix-config
# bootstrap
nix run nix-darwin -- switch --flake .#Seaholly
```

## Daily use
```bash
# rebuild and export artifacts
n
# update and rebuild
nix flake update && n
```

## Maintenance
```bash
nix-collect-garbage --delete-older-than 30d
nix-store --optimise
# if something breaks
darwin-rebuild --rollback
```

## Non-Nix machine emacs config
```bash
# symlink emacs configs to correct locations
ln -sfn "$(pwd)/home/emacs" "$HOME/.emacs.d"
```
