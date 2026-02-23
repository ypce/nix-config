{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    
    settings = {
      mgr = {
        ratio = [ 1 2 4 ];
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "none";
        show_hidden = false;
        show_symlink = true;
        scrolloff = 5;
      };
      
      preview = {
        wrap = "no";
        tab_size = 4;
        max_width = 6000;
        max_height = 8000;
      };

      opener = {
        emacs = [
          { run = "emacsclient -c -nw \"$@\""; block = true; }
        ];
      };
    };
    
    keymap = {
      mgr.prepend_keymap = [
        # Colemak navigation
        { on = [ "n" ]; run = "arrow 1"; desc = "Down"; }
        { on = [ "e" ]; run = "arrow -1"; desc = "Up"; }
        { on = [ "i" ]; run = "enter"; desc = "Enter"; }
        # Fast movement
        { on = [ "N" ]; run = "arrow 5"; desc = "Down 5"; }
        { on = [ "E" ]; run = "arrow -5"; desc = "Up 5"; }
        { on = [ "<C-n>" ]; run = "arrow 50%"; desc = "Half page down"; }
        { on = [ "<C-e>" ]; run = "arrow -50%"; desc = "Half page up"; }
        # Quick directory jumps
        { on = [ "g" "h" ]; run = "cd ~"; desc = "Go home"; }
        { on = [ "f" ]; run = ''shell 'emacsclient -c -nw -a "" "$@"' --block''; desc = "Open in Emacs"; }
        
      ];
      
      pick.prepend_keymap = [
        { on = [ "n" ]; run = "arrow 1"; desc = "Down"; }
        { on = [ "e" ]; run = "arrow -1"; desc = "Up"; }
      ];
      
      input.prepend_keymap = [
        { on = [ "<Esc>" ]; run = "close"; desc = "Cancel"; }
      ];
    };
    
    theme = {
      flavor = {
        dark = "dracula";
      };
      
      mgr = {
        border_symbol = " ";
        border_style = { fg = "#44475a"; };
      };
      
      status = {
        sep_open = "";
        sep_close = "";
      };
      
      tab = {
        sep_open = { open = ""; close = ""; };
        sep_close = { open = ""; close = ""; };
      };
      
      icon = {
        prepend_conds = [
          { "if" = "dir"; text = "󰉋"; }
        ];
      };
    };
  };

  xdg.configFile."yazi/flavors/dracula.yazi".source = ../yazi/flavors/dracula.yazi;
}
