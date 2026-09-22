{ config, lib, pkgs, ... }:

{
  home.file.".config/ghostty/config".text = ''
    # appearance
    theme = pro
    alpha-blending = native
    background-opacity = 0.90
    background-blur = 20
    window-colorspace = display-p3
    macos-titlebar-style = tabs
    macos-titlebar-proxy-icon = hidden
    macos-window-buttons = hidden
    macos-option-as-alt = true
    window-padding-x = 10
    window-padding-y = 10
    window-padding-balance = true
    window-padding-color = extend
    unfocused-split-opacity = 1

    # fonts
    # Family names must match what the font files report. AeonikMono
    # installs from private/fonts as "AeonikMono Nerd Font Mono", not
    # "Aeonik Mono". The old names matched nothing, so Ghostty fell back
    # to its default face.
    #
    # These are static OTFs with one file per weight, not variable
    # fonts (no fvar table), so font-variation had nothing to vary.
    # AeonikMono carries Light, Regular, Medium and Bold as separate
    # faces of one family, so pick the weight with font-style, which
    # takes the preferred subfamily name. The old wght=300 meant Light
    # and wght=800 meant the heaviest face, which is Bold.
    #
    # Give a family name, never a face name. Bold and italic faces come
    # from the family, so font-family-bold is unnecessary. Read the
    # family from `ghostty +list-fonts`, where the unindented line is
    # the family. The name table says "CaskaydiaCove NFM", but CoreText
    # presents the preferred family, "CaskaydiaCove Nerd Font Mono".
    font-size = 20
    font-family = AeonikMono Nerd Font Mono
    font-style = Light
    font-style-bold = Bold
    font-family-italic = CaskaydiaCove Nerd Font Mono
    font-family-bold-italic = CaskaydiaCove Nerd Font Mono
    window-title-font-family = AeonikMono Nerd Font Mono

    # safety nets
    confirm-close-surface = always
    quit-after-last-window-closed = false

    # shell integration so OSC 133, OSC 7, cursor shape etc. all work
    shell-integration = detect
    shell-integration-features = cursor,sudo,title

    # keep Cmd-based defaults (Cmd+T/W/N/D, Cmd+Shift+D, Cmd+[/], Cmd+1..9, Cmd+Alt+arrows)
    # only add the actions Ghostty doesn't ship a default for:
    keybind = cmd+shift+r=reload_config
    keybind = cmd+shift+e=equalize_splits
    keybind = cmd+shift+z=toggle_split_zoom
    keybind = cmd+shift+left=move_tab:-1
    keybind = cmd+shift+right=move_tab:1

    # if ever want to unbind a Ghostty default that collides with Emacs:
    # keybind = ctrl+tab=unbind
  '';

  home.file.".config/ghostty/themes/pro".source = ../ghostty/themes/pro;
}
