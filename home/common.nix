# Common home-manager config - runs on every host (macOS and future Linux).
# Keep this to portable CLI tooling only. Anything GUI or OS-flavoured lives
# in the per-platform home file (darwin.nix / linux.nix).

{ config, pkgs, userConfig, lib, ... }:
{
  imports = [
    ./modules/aria2-common.nix
  ];

  home.packages = with pkgs; [
    jless
    just
    fd
    jq
    gh
    fzf
    htop
    btop
    bat
    bitwarden-cli
    nixpkgs-fmt
    p7zip
    ncdu
    ripgrep
    tree
    exiftool
    rclone
    inetutils
    coreutils
    csvkit
    parallel
    httpie
    rsync
    sops
    age
    gitleaks

    # Language servers for eglot.
    gopls
    golangci-lint-langserver
    marksman
    ];

  programs.git = {
    enable = true;
    ignores = [ "justfile" ".DS_Store" ];
    signing.signByDefault = true;
    signing.key = "${config.home.homeDirectory}/.ssh/${userConfig.sshKey}";
    settings = {
      user.name = userConfig.github.username;
      user.email = userConfig.github.email;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
    };
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "${config.home.homeDirectory}/.ssh/config.private" ];
    settings = {
      "github github.com" = {
        HostName = "github.com";
        User = "git";
      };
      "yarrow yarrow.paulaus.com" = {
        HostName = "yarrow.paulaus.com";
        HostKeyAlias = "yarrow.local";
      };
      "*" = {
        AddKeysToAgent = "yes";
        SetEnv.TERM = "xterm-256color";
        IdentityFile = "${config.home.homeDirectory}/.ssh/${userConfig.sshKey}";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control-%C";
        ControlPersist = "1h";
      };
    };
  };

  home.file.".ssh/allowed_signers".text = ''
    ${userConfig.github.email} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeMEKO7ON5EW96d02wq8gYPavv2IFB3zlYAHotRC4Od vp
  '';

  home.sessionVariables = {
    NIXCONFIG_DIR = "${config.home.homeDirectory}/Git/nix-config";
    # Same key path on macOS and Linux. sops uses ~/Library/Application Support on macOS.
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
  
