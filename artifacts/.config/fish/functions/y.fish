function y --description="Open yazi and cd to the directory on exit"
    set -l tmp (mktemp -t "yazi-cwd.XXXXXXXX")

    command yazi --cwd-file="$tmp" $argv
    set -l st $status

    if test -f "$tmp"
        set -l cwd (string trim -- (cat "$tmp"))
        rm -f "$tmp"

        if test -n "$cwd"; and test -d "$cwd"
            cd "$cwd"
        end
    end

    return $st
end
