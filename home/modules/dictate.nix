# home/modules/dictate.nix
#
# Dictation in any app, local and without a GUI.
#
# Ctrl+Alt+D starts the recording. Ctrl+Alt+D again stops it. Then whisper.cpp
# transcribes the audio with base.en, and the text is pasted at the cursor.
# A sound and a notification show the start, the stop and errors. The orange
# microphone dot in the menu bar shows while the recording runs.
#
#   whisper-server  launchd agent, keeps the model in memory, 127.0.0.1:8178
#   skhd            the hotkey
#   dictate         records with sox, sends the audio to the server, pastes
#
# At the first use, macOS asks for some permissions. Give skhd Microphone and
# Accessibility access, let it control System Events, and allow notifications
# from Script Editor (osascript sends them). The binaries are in
# the Nix store, so after an update to sox or skhd, macOS can ask again.
# Logs: ~/Library/Logs/whisper-server.log

{ config, pkgs, ... }:

let
  port = 8178;

  model = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
    hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
  };

  dictate = pkgs.writeShellScriptBin "dictate" ''
    set -u
    dir="''${TMPDIR:-/tmp}/dictate"
    mkdir -p "$dir"
    wav="$dir/rec.wav"
    started="$dir/started"                      # exists while a recording runs
    lock="$dir/lock"

    sound() { /usr/bin/afplay "/System/Library/Sounds/$1.aiff" </dev/null >/dev/null 2>&1 & }
    notify() {
      /usr/bin/osascript -e "display notification \"$1\" with title \"Dictate\"" \
        </dev/null >/dev/null 2>&1 &
    }

    # One run at a time. Key repeat starts many runs, so drop the extra ones.
    # A lock older than 2 minutes is from a run that was killed.
    find "$lock" -maxdepth 0 -mmin +2 -exec rmdir {} \; 2>/dev/null
    mkdir "$lock" 2>/dev/null || exit 0
    trap 'rmdir "$lock"' EXIT

    now=''${EPOCHREALTIME/./}

    if [ ! -f "$started" ]; then
      # Start: record 16 kHz mono, the format whisper.cpp wants. Stop after 15 min.
      rm -f "$wav"
      echo "$now" > "$started"
      ${pkgs.sox}/bin/rec -q -c 1 -b 16 "$wav" rate 16k trim 0 15:00 \
        </dev/null >/dev/null 2>&1 &
      sound Tink
      notify "Recording. Press Ctrl+Alt+D to stop."
      exit 0
    fi

    # Stop. Ignore a press less than 0.7 s after the start (key repeat).
    (( now - $(cat "$started") < 700000 )) && exit 0
    rm -f "$started"

    # Stop all recorders that write to $wav, also any that a failed run left.
    # sox writes the WAV header when it gets SIGTERM.
    pkill -TERM -f -- "$wav"
    for _ in $(seq 40); do pgrep -f -- "$wav" >/dev/null || break; sleep 0.05; done
    pkill -KILL -f -- "$wav"

    sound Pop
    notify "Transcribing."
    if ! text=$(${pkgs.curl}/bin/curl -sf --max-time 120 "http://127.0.0.1:${toString port}/inference" \
        -F file=@"$wav" -F response_format=text -F temperature=0); then
      sound Basso
      notify "No answer from whisper-server. See ~/Library/Logs/whisper-server.log"
      exit 1
    fi
    rm -f "$wav"

    # Remove markers such as [BLANK_AUDIO], join the segments (each one starts
    # with a space), and make each run of spaces into one space.
    text=$(printf '%s' "$text" | sed -e 's/\[[A-Z_ ]*\]//g' | tr '\n' ' ' | tr -s ' ' \
      | sed -e 's/^ //' -e 's/ $//')
    if [ -z "$text" ]; then
      sound Basso
      notify "No speech found."
      exit 1
    fi

    # Paste, then put the old clipboard back.
    old=$(/usr/bin/pbpaste)
    printf '%s' "$text" | /usr/bin/pbcopy
    /usr/bin/osascript -e 'tell application "System Events" to keystroke "v" using command down'
    sleep 0.3
    printf '%s' "$old" | /usr/bin/pbcopy
  '';
in
{
  home.packages = [ dictate ];

  launchd.agents.whisper-server = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.whisper-cpp}/bin/whisper-server"
        "--model" "${model}"
        "--host" "127.0.0.1"
        "--port" (toString port)
        "--language" "en"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/whisper-server.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/whisper-server.log";
    };
  };

  services.skhd = {
    enable = true;
    config = ''
      ctrl + alt - d : ${dictate}/bin/dictate
    '';
  };

  # skhd does not read skhdrc again when the file changes, so restart it.
  xdg.configFile."skhd/skhdrc".onChange = ''
    /bin/launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.skhd"
  '';
}
