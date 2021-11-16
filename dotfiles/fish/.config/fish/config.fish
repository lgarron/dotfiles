# `config.fish`

# Setup

    # Only print if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    function _echo
        if isatty
            if not [ $SSH_TTY ]
                echo $argv
            end
        end
    end

    # Only print if we're a TTY that is not an SSH TTY.
    function __echo
        if not [ $SSH_TTY ]
            _echo $argv
        end
    end

    if [ "$MANUAL_RELOAD" = "true" ]
      _echo "[Reloading .fish files, including abbrevations defined from scratch]"
    end

    # Reloads the fish config file. `rc` is chosen because the config file for
    # other shells is often known as the `rc` file, and `rc` is easy to type.
    #
    # For this config file, `rc` will also force redefining abbreviations. See
    # the "Setup" section above.
    abbr -a rc ". $HOME/.config/fish/config.fish"

# Loading

    function loading_indicator
      if [ "$MANUAL_RELOAD" = "true" ]
        _echo -n "$argv[1]..."
      end
    end

    loading_indicator "config"

# XDG path configuration

    if test -f "$HOME/.config/fish/xdg-basedir-workarounds.fish"
      loading_indicator "xdg-basedir-workarounds"
      source "$HOME/.config/fish/xdg-basedir-workarounds.fish"
    end

# Machines

    set EUCLID Euclid euclid Euclid.local
    set GALOIS Galois galois Galois.local
    set MIRZAKHANI Mirzakhani mirzakhani Mirzakhani.local
    set MINITEMP Minitemp minitemp Minitemp.local

# MOTD

    function fish_greeting_echo
      for arg in $argv
        echo -n $arg | head -c(tput cols)
        echo ""
      end
      echo ""
    end

    # Based on: https://patorjk.com/software/taag/#p=display&v=1&f=Small&t=GALOIS
    function fish_greeting
      if contains (hostname -s) $GALOIS
        fish_greeting_echo \
            "  ___   _   _    ___ ___ ___ " \
            " / __| /_\\ | |  / _ \\_ _/ __|" \
            "| (_ |/ _ \\| |_| (_) | |\\__ \\" \
            " \\___/_/ \\_\\____\\___/___|___/"
      else if contains (hostname -s) $EUCLID
        fish_greeting_echo \
            " ___ _   _  ___ _    ___ ___  " \
            "| __| | | |/ __| |  |_ _|   \\ " \
            "| _|| |_| | (__| |__ | || |) |" \
            "|___|\\___/ \\___|____|___|___/ "
      else if contains (hostname -s) $MIRZAKHANI
        fish_greeting_echo \
            " __  __ ___ ___  ____  _   _  __ _  _   _   _  _ ___ " \
            "|  \\/  |_ _| _ \\|_  / /_\\ | |/ /| || | /_\\ | \\| |_ _|" \
            "| |\\/| || ||   / / /_/ _ \\| ' < | __ |/ _ \\| .` || | " \
            "|_|  |_|___|_|_\\/___/_/ \\_\\_|\\_\\|_||_/_/ \\_\\_|\\_|___|"
      else if contains (hostname -s) $MINITEMP
        fish_greeting_echo \
            " __  __ ___ _  _ ___ _____ ___ __  __ ___ " \
            "|  \\/  |_ _| \\| |_ _|_   _| __|  \\/  | _ \\" \
            "| |\\/| || || .` || |  | | | _|| |\\/| |  _/" \
            "|_|  |_|___|_|\\_|___| |_| |___|_|  |_|_|  "
      else if [ $CODESPACES = true ]
        fish_greeting_echo \
            "  ___ ___  ___  ___ ___ ___  _   ___ ___ ___ " \
            " / __/ _ \\|   \\| __/ __| _ \\/_\\ / __| __/ __|" \
            "| (_| (_) | |) | _|\\__ \\  _/ _ \\ (__| _|\\__ \\" \
            " \\___\\___/|___/|___|___/_|/_/ \\_\\___|___|___/"
      else
        echo "Welcome to "(hostname -s)
      end

    end

# Printing

    function echo-alternate-background
        set set_color_arg "normal"
        for arg in $argv[1..-1]
            set_color "$set_color_arg"
            echo -n $arg

            if [ "$set_color_arg" = "normal" ]
                set set_color_arg "-r"
            else
                set set_color_arg "normal"
            end
        end
        set_color "normal"
        echo ""
    end

    function echo-red
        set_color "red"
        echo $argv[1]
        set_color "normal"
    end

# Shortcuts

## Shell

    set DOTFILES_FOLDER ( \
        realpath ~/.config/fish/config.fish \
          | sed 's#dotfiles/fish/\.config/fish/config\.fish$##' \
    )
    abbr -a dff "$DOTFILES_FOLDER"

    abbr -a unset "set -e"

    function mkcd
        mkdir "$argv[1]"
        cd "$argv[1]"
    end

    # rbenv
    if type -q rbenv
        status --is-interactive; and source (rbenv init -|psub)
    end

    abbr -a "rmnm" "rm -rf ./node_modules ; and npm install"

    function bump-version
      # /usr/bin/env echo -n v
      npm version --no-git-tag-version $argv[1]
    end

    # Workaround for Codespaces
    # TODO: Remove once https://github.com/microsoft/vscode-dev-containers/pull/1138 is in new containers.
    functions -e code

### Editors

    set -x "EDITOR" "code -w"
    abbr -a c "code"
    abbr -a m "make"
    abbr -a xc "xargs code"

## Search

    function f
      find . -iname "*$argv[1]*"
    end

    function gre
      grep -ir $argv[1] .
    end

    # Until `ag` supports a config file:
    # https://github.com/ggreer/the_silver_searcher/pull/257
    abbr -a ag "ag --hidden"

    abbr -a rgnh "rg -S --no-heading"

## General


    # abbr -a t "tee >(pbcopy)"
    function t
        cat > /tmp/pbcopy.txt
        cat /tmp/pbcopy.txt
        cat /tmp/pbcopy.txt | pbcopy
        rm /tmp/pbcopy.txt
    end

    function o
        if [ (count $argv) = 0 ]
            open .
        else
            open $argv
        end
    end

    set STDERRED_PATH "$HOME/Code/git/github.com/sickill/stderred/builda/libtest_stderred.dylib"
    if test -f "$STDERRED_PATH"
        set -x DYLD_INSERT_LIBRARIES "$STDERRED_PATH"
        # I can't get STDERRED_BLACKLIST to work, so let's make it easy to unset DYLD_INSERT_LIBRARIES
        abbr -a "dy" "set -e DYLD_INSERT_LIBRARIES"
    end

    abbr -a serve "open http://localhost:8000; caddy file-server --listen :8000 --browse"

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

    set -x "DANCE_HACKING_MUSIC_FOLDER" "$HOME/Desktop/Music/"

    function aedeploy
      _echo "Invoking wrapped aedeploy."
      env DYLD_INSERT_LIBRARIES='' command aedeploy $argv
    end

    function mac-add-dock-spacer
      defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
      killall Dock
    end

## Keyboard

    # https://developer.apple.com/library/content/technotes/tn2450/_index.html
    # Caps Lock (0x39) -> Delete Key (0x2A)
    function remap-keys-caps-lock-to-backspace
        hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000002A}]}'
    end

    function remap-keys-reset
        hidutil property --set '{"UserKeyMapping":[]}'
    end

    function remap-keys-show
        hidutil property --get "UserKeyMapping"
    end

## Web

    function https
        http --default-scheme https $argv
    end

    # *h*ttps *h*eaders
    abbr -a "hh" "https -ph"

# Shortcuts

    function mac-add-shortcut
        echo-alternate-background \
            "Setting shortcut for " "$argv[1]" \
            " > " "$argv[2]" \
            " to " "$argv[3]"

        if defaults read com.apple.universalaccess "com.apple.custommenu.apps" | grep "\"$argv[1]\"" > /dev/null
        else
            defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "$argv[1]"
        end
        defaults write "$argv[1]" NSUserKeyEquivalents -dict-add "$argv[2]" -string "$argv[3]"
    end

    function mac-add-shortcut-to-all-chromes
        mac-add-shortcut "com.google.Chrome"        $argv
        mac-add-shortcut "com.google.Chrome.canary" $argv
        mac-add-shortcut "org.chromium.Chromium"    $argv
    end

    function mac-setup-shortcuts-auto
        mac-add-shortcut-to-all-chromes "Extensions" "\$@e"
        # Save
        mac-add-shortcut "org.audacityteam.audacity" "Save Project As…" "\$@s"
        # Export
        mac-add-shortcut "com.bloombuilt.dayone-mac" "JSON" "\$@e"
        mac-add-shortcut "com.apple.iMovieApp" "File…" "\$@e"
        mac-add-shortcut "com.apple.iWork.Pages" "PDF…" "\$@e"
        mac-add-shortcut "com.apple.garageband10" "Export Song to Disk…" "\$@e"
        mac-add-shortcut "com.adobe.lightroomCC" "Export" "\$@e"
        mac-add-shortcut "com.apple.FinalCut" "HEVC (H.265) up to 4K…" "\$@e"
        # Refresh
        mac-add-shortcut "com.apple.Safari" "Reload Page From Origin" "\$@r"
        # Paste and Match Style
        mac-add-shortcut "com.tinyspeck.slackmacgap" "Paste and Match Style" "\$@v"
        mac-add-shortcut "com.apple.iWork.Pages" "Paste and Match Style" "\$@v"
        mac-add-shortcut "com.bloombuilt.dayone-mac" "Paste as Plain Text" "\$@v"
        mac-add-shortcut "com.apple.AddressBook" "Edit Card" "\$e"
    end

    function pnice
      set NICENESS $argv[2]
      echo "📶 Setting niceness $NICENESS for process names containing: $argv[1]";
      for pid in (pgrep $argv[1])
            echo -n "🖥  renice $NICENESS $pid"
            renice $NICENESS $pid 2> /dev/null
            if test $status -ne 0
                  echo -n " (sudo)"
                  sudo renice $NICENESS $pid
                end
            echo ""
          end
    end

    function niceplz
      # Prioritize Quicksilver.
      # I use it all the time, and it's a canary for system overload.
      pnice "Quicksilver" "-20"
      # Syncing processes.
      pnice "Dropbox" 19
      pnice "Backup and Sync" 19
      pnice "CCC User Agent" 19
      echo "sudo for Time Machine (Ctrl-C to skip Time Machine)"
      sudo echo -n "" ; or return
      pnice "backupd" 19
    end

# Screenshots

    function set-screenshot-dir
        set DIR $argv[1]
        echo-alternate-background "Setting screenshot dir to: " "$DIR"
        defaults write com.apple.screencapture location $argv[1]
        killall SystemUIServer
    end

    function set-screenshot-dir-auto
      set HOSTNAME_SHORT (hostname -s)
      if contains $HOSTNAME_SHORT $EUCLID
        set-screenshot-dir "$HOME/Dropbox/Screenshots/Euclid Screenshots/Euclid Screenshots 2018/"
      else if contains $HOSTNAME_SHORT $MIRZAKHANI
        set-screenshot-dir "$HOME/Google Drive/Screenshots/Mirzakhani Screenshots/"
      else
        echo-red "Could not determine screenshot directory."
        return 1
      end
    end

# Setup

    function mac-fish-setup
        mac-setup-shortcuts-auto
        set-screenshot-dir-auto
    end

# From automatic additions:

## Wasienv

    export WASIENV_DIR="/Users/lgarron/.wasienv"
    [ -s "$WASIENV_DIR/wasienv.sh" ] && source "$WASIENV_DIR/wasienv.sh"

## Wasmer

    export WASMER_DIR="/Users/lgarron/.wasmer"
    [ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

## google-cloud-sdk

    if test -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc"
      source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc"
    end

# Includes

    function load_if_exists
      if test -f $argv[2]
        loading_indicator $argv[1]
        source $argv[2]
      end
    end

    load_if_exists "git" "$HOME/.config/fish/git.fish"
    load_if_exists "go" "$HOME/.config/fish/go.fish"
    load_if_exists "chrome" "$HOME/.config/fish/chrome.fish"
    load_if_exists "local" "$HOME/.config/fish/local.fish"

    _echo -ne "\r" # Clear loading indicators.

# Cleanup

    # From now on, reloads of this file are considered "manual".
    set MANUAL_RELOAD true
