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
      for a in (abbr --list)
        abbr -e $a
      end
    else
      # Don't try to load any abbreviations (much faster).
      function abbr
      end
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

# Machines

    set EUCLID Euclid euclid Euclid.local
    set GALOIS Galois galois Galois.local
    set NOETHER Noether noether
    set AGNESI Agnesi agnesi
    set HYPATIA Hypatia hypatia lgarron-macpro
    set LGARRON1 lgarron1
    set LOVELACE lovelace

    set MACHINE_GROUP_LINUX_WORKSTATION $LGARRON1 $LOVELACE

# Path

    if contains (hostname -s) $EUCLID
        set PATH \
            $PATH \
            "$HOME/local/brew/bin" \
            "$HOME/local/bin/misc" \
            "$HOME/local/bin/scripts" \
            "$HOME/local/bin/dance-hacking"
    end

    if contains (hostname -s) $GALOIS
        set PATH \
            $PATH \
            "$HOME/local/bin/misc" \
            "$HOME/local/bin/scripts" \
            "$HOME/local/bin/dance-hacking"
    end

    if contains (hostname -s) $NOETHER
        set PATH \
            "/usr/local/git/current/bin" \
            "$HOME/local/brew/bin" \
            $PATH 
    end

    if contains (hostname -s) $AGNESI
        set PATH \
            "/usr/local/git/current/bin" \
            "$HOME/local/brew/bin" \
            $PATH 
    end

    if contains (hostname -s) $HYPATIA
        set PATH \
            # "$HOME/local/bin-front-of-path" \
            "/usr/local/git/current/bin" \
            "$HOME/local/homebrew/bin" \
            $PATH \
            # "$HOME/local/bin/misc" \
            "$HOME/Code/Work/google-cloud-sdk/bin"
    end

    # https://superuser.com/a/1212305
    function removepath
        if set -l index (contains -i $argv[1] $PATH)
            set --erase --universal fish_user_paths[$index]
        end
    end

    if contains (hostname -s) $MACHINE_GROUP_LINUX_WORKSTATION
        removepath "/usr/local/buildtools/java/jdk/bin"
    end

# MOTD

    function fish_greeting

      if contains (hostname -s) $GALOIS
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=Galois%0AGALOIS
        __echo " ██████     █████    ██         ██████    ██   ███████ "
        __echo "██         ██   ██   ██        ██    ██   ██   ██      "
        __echo "██   ███   ███████   ██        ██    ██   ██   ███████ "
        __echo "██    ██   ██   ██   ██        ██    ██   ██        ██ "
        __echo " ██████    ██   ██   ███████    ██████    ██   ███████ "
        __echo ""
      else if contains (hostname -s) $NOETHER
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=NOETHER
        __echo "███    ██  ██████  ███████ ████████ ██   ██ ███████ ██████ "
        __echo "████   ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        __echo "██ ██  ██ ██    ██ █████      ██    ███████ █████   ██████ "
        __echo "██  ██ ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        __echo "██   ████  ██████  ███████    ██    ██   ██ ███████ ██   ██"
        __echo ""
      else if contains (hostname -s) $AGNESI
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=AGNESI
        __echo " █████   ██████  ███    ██ ███████ ███████ ██"
        __echo "██   ██ ██       ████   ██ ██      ██      ██"
        __echo "███████ ██   ███ ██ ██  ██ █████   ███████ ██"
        __echo "██   ██ ██    ██ ██  ██ ██ ██           ██ ██"
        __echo "██   ██  ██████  ██   ████ ███████ ███████ ██"
        __echo ""
      else if contains (hostname -s) $HYPATIA
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=HYPATIA
        __echo "██   ██ ██    ██ ██████   █████  ████████ ██  █████ "
        __echo "██   ██  ██  ██  ██   ██ ██   ██    ██    ██ ██   ██"
        __echo "███████   ████   ██████  ███████    ██    ██ ███████"
        __echo "██   ██    ██    ██      ██   ██    ██    ██ ██   ██"
        __echo "██   ██    ██    ██      ██   ██    ██    ██ ██   ██"
      else if contains (hostname -s) $LGARRON1
        __echo "██       ██████   █████  ██████  ██████   ██████  ███    ██  ██"
        __echo "██      ██       ██   ██ ██   ██ ██   ██ ██    ██ ████   ██ ███"
        __echo "██      ██   ███ ███████ ██████  ██████  ██    ██ ██ ██  ██  ██"
        __echo "██      ██    ██ ██   ██ ██   ██ ██   ██ ██    ██ ██  ██ ██  ██"
        __echo "███████  ██████  ██   ██ ██   ██ ██   ██  ██████  ██   ████  ██"
        __echo ""
      else if contains (hostname -s) $LOVELACE
        __echo "██       ██████  ██    ██ ███████ ██       █████   ██████ ███████"
        __echo "██      ██    ██ ██    ██ ██      ██      ██   ██ ██      ██     "
        __echo "██      ██    ██ ██    ██ █████   ██      ███████ ██      █████  "
        __echo "██      ██    ██  ██  ██  ██      ██      ██   ██ ██      ██     "
        __echo "███████  ██████    ████   ███████ ███████ ██   ██  ██████ ███████"
        __echo ""
      else if contains (hostname -s) $EUCLID
        __echo "███████ ██    ██  ██████ ██      ██ ██████ "
        __echo "██      ██    ██ ██      ██      ██ ██   ██"
        __echo "█████   ██    ██ ██      ██      ██ ██   ██"
        __echo "██      ██    ██ ██      ██      ██ ██   ██"
        __echo "███████  ██████   ██████ ███████ ██ ██████ "
      else
        __echo "Welcome to "(hostname -s)
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
        python -c 'import os, sys; print os.path.realpath(sys.argv[1])' \
            ~/.config/fish/config.fish \
            | sed 's#dotfiles/fish/\.config/fish/config\.fish$##')
    abbr -a dff "$DOTFILES_FOLDER"

    abbr -a unset "set -e"

    function mkcd
        mkdir "$argv[1]"
        cd "$argv[1]"
    end

### Editors

    set -x "EDITOR" "subl -w"
    abbr -a s "subl"

    # TODO: Remove if https://github.com/facebook/PathPicker/issues/269 is fixed.
    set -x FPP_DIR "$HOME/.cache/fpp/"

## Search

    if command -s mdfind > /dev/null
        # mdfind is much faster on macOS.
        abbr -a f "mdfind -onlyin (pwd) -name"
    else
        function f
          find . -iname "*$argv[1]*"
        end
    end

    function gre
      grep -ir $argv[1] .
    end

    # Until `ag` supports a config file:
    # https://github.com/ggreer/the_silver_searcher/pull/257
    abbr -a ag "ag --hidden"

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

    abbr -a xs "xargs subl"

    set STDERRED_PATH "$HOME/local/dylib/libstderred.dylib"
    if test -f "$STDERRED_PATH"
        export DYLD_INSERT_LIBRARIES=""
        # I can't get STDERRED_BLACKLIST to work, so let's make it easy to unset DYLD_INSERT_LIBRARIES
        abbr -a "dy" "set -e DYLD_INSERT_LIBRARIES"
    end

    abbr -a serve "python -m SimpleHTTPServer"

    # Technically a private API token, but not critically secret.
    set -x "_ECHO_NEST_API_KEY" "EJ7ZVMPNXWVFXS1KE"

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

## iTerm

    function source_iterm_shell_integration
      if not functions -q iterm_fish_prompt
        set file "$HOME/.iterm2_shell_integration.fish"
        if test -f "$file"
          source "$file"
        else
          _echo "Could not find iTerm shell integration file: $file"
        end
      end
    end

    if [ (uname) = "Darwin" ]
      source_iterm_shell_integration
    else
      if [ $SSH_TTY ]
        source_iterm_shell_integration
      end
    end

    functions -e source_iterm_shell_integration

# SSH configs

    if contains (hostname -s) $MACHINE_GROUP_LINUX_WORKSTATION
      if [ $SSH_TTY ]

        function subl
            rmate $argv
        end
        set -x "EDITOR" "rmate -w"

        set -x "DISPLAY" ":20"

      end
    end

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
        mac-add-shortcut "com.google.Chrome" "Vertical Reviewers" "^v"
        mac-add-shortcut "com.google.Chrome" "Copy Issue URL" "^c"
        mac-add-shortcut "com.google.Chrome" "Copy Issue for Snippets" "^s"
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
      if contains $HOSTNAME_SHORT $NOETHER
        set-screenshot-dir "$HOME/Dropbox/Screenshots/Euclid Screenshots/"
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

# Includes

    loading_indicator "git"
    if test -f "$HOME/.config/fish/git.fish"
      source "$HOME/.config/fish/git.fish"
    end

    loading_indicator "go"
    if test -f "$HOME/.config/fish/go.fish"
      source "$HOME/.config/fish/go.fish"
    end

    loading_indicator "chrome"
    if test -f "$HOME/.config/fish/chrome.fish"
      source "$HOME/.config/fish/chrome.fish"
    end

    _echo -ne "\r" # Clear loading indicators.

# Cleanup

    if [ "$MANUAL_RELOAD" != "true" ]
        functions -e abbr
    end
    # From now on, reloads of this file considered "manual".
    set MANUAL_RELOAD true