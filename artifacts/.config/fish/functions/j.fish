function j
    set -l dir (fd -t d -H --max-depth 5 . ~ 2>/dev/null | fzf --reverse --height 40% --prompt="Navigate to: ")
    test -n "$dir"; and cd "$dir"
end
