# `config.fish`

# Setup

    function add_to_path_if_exists
      set NEW_PATH_COMPONENT $argv[1]
      if test -d $NEW_PATH_COMPONENT
        set PATH $PATH $NEW_PATH_COMPONENT
      end
    end

    add_to_path_if_exists /opt/homebrew/bin # macOS (Apple Silicon)
    add_to_path_if_exists /home/linuxbrew/.linuxbrew/bin # for codespaces
    add_to_path_if_exists /home/linuxbrew/.linuxbrew/sbin # for codespaces

    # Only print if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    function _echo
        if isatty
            if not [ $SSH_TTY ]
                echo $argv
            end
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
    set MIRZAKHANI2 Mirzakhani2 mirzakhani2 Mirzakhani2.local
    set GERMAIN Germain germain Germain.local
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
      else if contains (hostname -s) $MIRZAKHANI2
        fish_greeting_echo \
            " __  __ ___ ___  ____  _   _  ___  _   _   _  _ ___ ___ " \
            "|  \\/  |_ _| _ \\|_  / /_\\ | |/ / || | /_\\ | \\| |_ _|_  )" \
            "| |\\/| || ||   / / / / _ \\| ' <| __ |/ _ \\| .\` || | / / " \
            "|_|  |_|___|_|_\\/___/_/ \\_\\_|\\_\\_||_/_/ \\_\\_|\\_|___/___|"
      else if contains (hostname -s) $MIRZAKHANI
        fish_greeting_echo \
            " __  __ ___ ___  ____  _   _  __ _  _   _   _  _ ___ " \
            "|  \\/  |_ _| _ \\|_  / /_\\ | |/ /| || | /_\\ | \\| |_ _|" \
            "| |\\/| || ||   / / /_/ _ \\| ' < | __ |/ _ \\| .\` || | " \
            "|_|  |_|___|_|_\\/___/_/ \\_\\_|\\_\\|_||_/_/ \\_\\_|\\_|___|"
      else if contains (hostname -s) $GERMAIN
        fish_greeting_echo \
            "  ___ ___ ___ __  __   _   ___ _  _ " \
            " / __| __| _ \\  \\/  | /_\\ |_ _| \\| |" \
            "| (_ | _||   / |\\/| |/ _ \\ | || .` |" \
            " \\___|___|_|_\\_|  |_/_/ \\_\\___|_|\\_|"
      else if contains (hostname -s) $MINITEMP
        fish_greeting_echo \
            " __  __ ___ _  _ ___ _____ ___ __  __ ___ " \
            "|  \\/  |_ _| \\| |_ _|_   _| __|  \\/  | _ \\" \
            "| |\\/| || || .` || |  | | | _|| |\\/| |  _/" \
            "|_|  |_|___|_|\\_|___| |_| |___|_|  |_|_|  "
      #else if [ $CODESPACES = true ]
      #  fish_greeting_echo \
      #      "  ___ ___  ___  ___ ___ ___  _   ___ ___ ___ " \
      #      " / __/ _ \\|   \\| __/ __| _ \\/_\\ / __| __/ __|" \
      #      "| (_| (_) | |) | _|\\__ \\  _/ _ \\ (__| _|\\__ \\" \
      #      " \\___\\___/|___/|___|___/_|/_/ \\_\\___|___|___/"
      else
        echo -n "🐟 Welcome to "
        set_color --bold; echo (hostname -s)
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

    function mkcd
        mkdir "$argv[1]"
        cd "$argv[1]"
    end

    abbr -a niy "npm init -y"
    abbr -a ni "npm install;"
    abbr -a nis "npm install --save"
    abbr -a nid "npm install --save-dev"
    abbr -a nu "npm uninstall"
    abbr -a "rmnm" "rm -rf ./node_modules ; and npm install"

    function bump-version
      # /usr/bin/env echo -n v
      npm version --no-git-tag-version $argv[1]
    end

### Editors

    # TODO: https://github.com/microsoft/vscode/issues/139634
    set -x "VISUAL" (which code)" -w"
    set -x "EDITOR" "code -w"
    # set -x EDITOR "open -b com.microsoft.VSCode"

    abbr -a c "code"
    abbr -a xc "xargs code"

    abbr -a m "make"
    abbr -a mb "make build"
    abbr -a mc "make clean"
    abbr -a md "make dev"
    abbr -a ml "make deploy"
    abbr -a mp "make publish"
    abbr -a mt "make test"

    if [ (uname) = "Darwin" ]
      function code
      echo $argv
        # `open -b` fails for creating files in new directories, so we touch the files first.
        # This changes the default behaviour of VSCode (create the file and the intermediate directory on first save), but it's acceptable as a workaround for https://github.com/microsoft/vscode/issues/139634
        for file in $argv
          mkdir -p (dirname $file)
        end
        touch -- $argv
        open -b com.microsoft.VSCode $argv
      end
    end

## Search

    function f
      find . -iname "*$argv[1]*"
    end

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

    abbr -a r "open -R"

    abbr -a bi "brew install"

    # set STDERRED_PATH "$HOME/Code/git/github.com/sickill/stderred/builda/libtest_stderred.dylib"
    # if test -f "$STDERRED_PATH"
    #     set -x DYLD_INSERT_LIBRARIES "$STDERRED_PATH"
    #     # I can't get STDERRED_BLACKLIST to work, so let's make it easy to unset DYLD_INSERT_LIBRARIES
    #     abbr -a "dy" "set -e DYLD_INSERT_LIBRARIES"
    # end

    abbr -a serve "open http://localhost:8000; caddy file-server --listen :8000 --browse"

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

    abbr -a "yarn" "npx yarn"
    set -x "EXPERIMENTAL_CUBING_JS_RELOAD_CHROME_MACOS" "1"

    function aedeploy
      _echo "Invoking wrapped aedeploy."
      env DYLD_INSERT_LIBRARIES='' command aedeploy $argv
    end

    function mac-add-dock-spacer
      defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
      killall Dock
    end

    function vscode_recording
      cat "$HOME/Library/Application Support/Code/User/settings.json" \
        | jq ".\"terminal.integrated.defaultProfile.osx\" = \"apple_silicon_fish_no_history\"" \
        | jq ".\"editor.formatOnType\" = false" \
        | jq ".\"editor.formatOnPaste\" = false" \
        | jq ".\"editor.formatOnSave\" = false" \
        | jq ".\"window.zoomLevel\" = 4" \
        > /tmp/file.txt; \
        and cat /tmp/file.txt \
        > "$HOME/Library/Application Support/Code/User/settings.json"
    end

    function vscode_unrecording
      cat "$HOME/Library/Application Support/Code/User/settings.json" \
        | jq ".\"terminal.integrated.defaultProfile.osx\" = \"apple_silicon_fish\"" \
        | jq ".\"editor.formatOnType\" = true" \
        | jq ".\"editor.formatOnPaste\" = true" \
        | jq ".\"editor.formatOnSave\" = true" \
        | jq ".\"window.zoomLevel\" = 3" \
        > /tmp/file.txt; \
        and cat /tmp/file.txt \
        > "$HOME/Library/Application Support/Code/User/settings.json"
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
            if defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "$argv[1]"
            else
              echo "Try `mac-add-shortcut` in a terminal app?"
            end
        end
        if defaults write "$argv[1]" NSUserKeyEquivalents -dict-add "$argv[2]" -string "$argv[3]"
        else
          echo "Try `mac-add-shortcut` in a terminal app?"
        end
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
        mac-add-shortcut "com.adobe.mas.lightroomCC" "Export…" "\$@e"
        # mac-add-shortcut "com.adobe.mas.lightroomCC" "Edit in Photoshop…" "\$@p"
        mac-add-shortcut "com.apple.FinalCut" "HEVC (H.265) up to 4K…" "\$@e"
        # Refresh
        mac-add-shortcut "com.apple.Safari" "Reload Page From Origin" "\$@r"
        # Paste and Match Style
        mac-add-shortcut "com.tinyspeck.slackmacgap" "Paste and Match Style" "\$@v"
        mac-add-shortcut "com.apple.iWork.Pages" "Paste and Match Style" "\$@v"
        mac-add-shortcut "com.bloombuilt.dayone-mac" "Paste as Plain Text" "\$@v"
        # Consistency with other programs
        mac-add-shortcut "com.apple.AddressBook" "Edit Card" "\$e"
    end

    function pnice
      set NICENESS $argv[2]
      if test (count $argv) -lt 2
        echo "Usage: pnice <process substring> <niceness>"
      else
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
    end

    function pnicest
      pnice $argv[1] 19
    end

    function niceplz
      # Prioritize Quicksilver.
      # I use it all the time, and it's a canary for system overload.
      pnice "Quicksilver" "-20"
      # Syncing processes.
      pnicest "Dropbox"
      pnicest "Backup and Sync"
      pnicest "Google Drive"
      pnicest "CCC User Agent"
      pnicest "CloneKitService" # Custom CCC process name prefix
      pnicest "Maestral"
      pnicest "Compressor"
      pnicest "VTEncoderXPCService" # main encoding process used by Compressor?
      pnicest "Spotlight"
      pnicest "mds_stores"
      pnicest "mdsync"
      pnicest "mdworker_shared"
      pnicest "com.carbonblack.es-loader.es-extension"
      pnicest "ArqAgent"
      pnicest "zoom.us"
      echo "sudo for Time Machine (Ctrl-C to skip Time Machine)"
      sudo echo -n "" ; or return
      pnicest "backupd"
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

    if which rbenv > /dev/null
      status --is-interactive; and rbenv init - fish | source
    end

    # Manual workaround for bun, until one of the following is resolved:
    # - https://github.com/oven-sh/bun/issues/272
    # - https://github.com/oven-sh/bun/issues/965
    add_to_path_if_exists "$HOME/.local/bin"
