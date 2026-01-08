{ config, lib, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    
    # Default editor
    defaultEditor = true;
    
    settings = {
      theme = "dracula-clear";
      
      editor = {
        auto-completion = true;
        auto-format = true;
        auto-save = true;
        bufferline = "always";
        completion-trigger-len = 1;
        color-modes = true;
        cursorline = true;
        line-number = "relative";
        mouse = true;
        shell = ["bash" "-c"];
        
        gutters = {
          layout = ["diff" "diagnostics" "spacer"];
        };
        
        file-picker = {
          hidden = false;
        };
        
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        
        indent-guides = {
          render = true;
        };
        
        lsp = {
          display-messages = true;
        };
        
        soft-wrap = {
          enable = true;
          max-wrap = 25;
          max-indent-retain = 0;
          wrap-indicator = "";
        };
        
        statusline = {
          left = ["mode" "spinner" "position" "position-percentage"];
          center = ["file-name"];
          right = ["file-encoding" "file-line-ending" "file-type"];
          separator = "|";
          mode = {
            normal = "NOR";
            insert = "INS";
            select = "SEL";
          };
        };
      };
      
      keys = {
        normal = {
          a = ["append_mode" "collapse_selection"];
          E = ["extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before"];
          G = "goto_last_line";
          N = ["extend_to_line_bounds" "delete_selection" "paste_after"];
          pagedown = ["half_page_down" "goto_window_center"];
          pageup = ["half_page_up" "goto_window_center"];
          
          # Custom HNEI navigation (Colemak-style)
          h = "move_char_left";
          n = "move_line_down";
          e = "move_line_up";
          i = "move_char_right";
          
          l = "insert_mode";
          L = "insert_at_line_start";
          o = "open_below";
          O = "open_above";
          j = "move_next_word_end";
          J = "move_next_long_word_end";
          k = "search_next";
          K = "search_prev";
          
          "C-/" = ["toggle_comments"];
          C-h = "goto_previous_buffer";
          C-i = "goto_next_buffer";
          C-x = ":buffer-close";
          
          space.w = {
            n = "jump_view_left";
            e = "jump_view_down";
            i = "jump_view_up";
            o = "jump_view_right";
          };
          
          g = {
            h = "hover";
            a = "code_action";
          };
          
          z = {
            n = "scroll_down";
            e = "scroll_up";
          };
          
          Z = {
            n = "scroll_down";
            e = "scroll_up";
          };
        };
        
        select = {
          G = "goto_last_line";
          h = "move_char_left";
          n = "move_line_down";
          e = "move_line_up";
          i = "move_char_right";
          l = "insert_mode";
          L = "insert_at_line_start";
          o = "open_below";
          O = "open_above";
          j = "move_next_word_end";
          J = "move_next_long_word_end";
          k = "search_next";
          K = "search_prev";
        };
      };
    };
    
    # Language configuration
    languages = {
      language-server = {
        gopls = {
          command = "gopls";
        };
        
        golangci-lint-lsp = {
          command = "golangci-lint-langserver";
        };
        
        scls = {
          command = "simple-completion-language-server";
          config = {
            max_completion_items = 20;
            snippets_first = true;
            feature_words = true;
            feature_snippets = true;
            feature_unicode_input = true;
            feature_paths = true;
          };
          environment = {
            RUST_LOG = "info,simple-completion-langauge-server=info";
            LOG_FILE = "/tmp/completion.log";
          };
        };
        
        marksman = {
          command = "marksman";
        };
        
        markdown-oxide = {
          command = "markdown-oxide";
        };
      };
      
      language = [
        {
          name = "go";
          scope = "source.go";
          injection-regex = "go";
          file-types = ["go"];
          roots = ["go.work" "go.mod"];
          auto-format = true;
          comment-token = "//";
          language-servers = ["gopls" "golangci-lint-lsp"];
          indent = {
            tab-width = 4;
            unit = "\t";
          };
        }
        {
          name = "markdown";
          injection-regex = "md|markdown";
          file-types = ["md" "markdown" "mkd" "mkdn" "mdwn" "mdown" "markdn" "mdtxt" "mdtext" "workbook"];
          language-servers = ["scls" "marksman" "markdown-oxide"];
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          block-comment-tokens = {
            start = "<!--";
            end = "-->";
          };
        }
        {
          name = "git-commit";
          language-servers = ["scls"];
        }
      ];
    };
  };
  
  # Copy custom themes if you have them
  home.file.".config/helix/themes" = lib.mkIf (builtins.pathExists ../helix/themes) {
    source = ../helix/themes;
    recursive = true;
  };
  
  # Install language servers
  home.packages = with pkgs; [
    # Go
    gopls
    golangci-lint-langserver
    
    # Markdown
    marksman
    markdown-oxide
    
    # Generic completion
    simple-completion-language-server
  ];
}
