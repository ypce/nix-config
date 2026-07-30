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
    font-size = 20
    font-family = Aeonik Mono
    font-variation = wght=300
    font-variation = wdth=100
    font-family-bold = Aeonik Mono Bold
    font-variation-bold = wght=800
    font-family-italic = CaskaydiaCove Nerd Font Mono
    font-variation-italic = wght=200
    font-family-bold-italic = CaskaydiaCove Nerd Font Mono
    font-variation-bold-italic = wght=800
    window-title-font-family = Aeonik Mono

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
