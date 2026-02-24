# Common home-manager configurations
# Contains options common to any host, such as editor and shell configurations.

{ config, pkgs, userConfig, lib, ... }:
let
  flakeRoot = builtins.toString ./.;
in
{
  imports = [
    ./modules/aria2-common.nix
    ./modules/ghostty.nix
    ./modules/fish.nix
    ./modules/helix.nix
    ./modules/yazi.nix
  ];

  home.packages = with pkgs; [
    jless
    just
    fd
    gh
    glow
    fzf
    htop
    btop
    bat
    helix
    lazygit
    nixpkgs-fmt
    p7zip
    ncdu
    ripgrep
    tmux
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

  programs.tmux = {
    enable = true;
    mouse = true;
    prefix = "C-Space";
    extraConfig = ''
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %
    '';
    plugins = with pkgs; [
      tmuxPlugins.prefix-highlight
      {
        plugin = tmuxPlugins.prefix-highlight;
        extraConfig = ''
          set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
          set -g status-right '#{prefix_highlight} | %a %Y-%m-%d %H:%M'
        '';
      }
    ];
  };
}
  
