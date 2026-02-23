if test "$TERM" = xterm-ghostty
    set -gx TERM xterm-256color
end
# Default Editor
set -gx EDITOR hx
set -gx VISUAL hx
# Colors for CLI tools
set -gx CLICOLOR 1
set -gx LSCOLORS ExFxCxDxBxegedabagacad
# Prevent homebrew auto-update
set -gx HOMEBREW_NO_AUTO_UPDATE 1
status is-login; and begin
    # Login shell initialisation
end
status is-interactive; and begin
    # Abbreviations
    # Aliases
    alias .. 'cd ..'
    alias cp 'cp -rv'
    alias edaemon 'emacs --bg-daemon'
    alias gc 'git clone'
    alias grep 'grep --color=auto'
    alias gst 'git status'
    alias lg lazygit
    alias mkdir 'mkdir -pv'
    alias mv 'mv -v'
    alias q exit
    alias rm 'rm -i'
    alias so 'rclone bisync ~/Org/ yarrow-sftp:/ --check-access --conflict-resolve newer --conflict-loser num --conflict-suffix '\''conflict-{DateOnly}'\'' --create-empty-src-dirs --resilient --recover --max-lock 2m -MvP'
    # Interactive shell initialisation
    # Custom greeting
    set fish_greeting
    # Auto-configure Tide on first run (only runs once)
    if not set -q tide_configured
        tide configure --auto --style=Lean --prompt_colors='True color' --show_time=No --lean_prompt_height='One line' --prompt_spacing=Compact --icons='Few icons' --transient=No
        set -U tide_configured yes
    end
    zoxide init fish | source
    atuin init fish | source
    direnv hook fish | source
end
