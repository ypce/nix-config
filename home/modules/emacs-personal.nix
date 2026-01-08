{ config, lib, pkgs, ... }:

{
  home.file.".emacs.d/init.el".source = ../emacs/init.el;
  home.file.".emacs.d/early-init.el".source = ../emacs/early-init.el;
  home.file.".emacs.d/programming.el".source = ../emacs/programming.el;
  home.file.".emacs.d/dracula-pro-pro-theme.el".source = ../emacs/themes/dracula-pro-pro-theme.el;
}
