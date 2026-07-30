# Common home-manager config - runs on every host (macOS and future Linux).
# Keep this to portable CLI tooling only. Anything GUI or OS-flavoured lives
# in the per-platform home file (darwin.nix / linux.nix).

{ config, pkgs, userConfig, lib, ... }:
let
  flakeRoot = builtins.toString ./.;
in
{
  imports = [
    ./modules/aria2-common.nix
    ./modules/helix.nix
    ./modules/yazi.nix
  ];

  home.packages = with pkgs; [
    jless
    just
    fd
    jq
    gh
    glow
    fzf
    htop
    btop
    bat
    bitwarden-cli
      lazygit
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
    extraConfig = lib.mkBefore ''
    Include ${config.home.homeDirectory}/.ssh/config.private
    AddKeysToAgent yes
    '';
    matchBlocks = {
      "github github.com" = {
        hostname = "github.com";
        user = "git";
      };
      "*" = {
        extraOptions.SetEnv = "TERM=xterm-256color";
        identityFile = "${config.home.homeDirectory}/.ssh/${userConfig.sshKey}";
        controlMaster = "auto";
        controlPersist = "1h";
      };
    };
  };

  home.file.".ssh/allowed_signers".text = ''
    ${userConfig.github.email} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeMEKO7ON5EW96d02wq8gYPavv2IFB3zlYAHotRC4Od vp
  '';

  home.sessionVariables = {
    NIXCONFIG_DIR = "${config.home.homeDirectory}/Git/nix-config";
  };
}
  
