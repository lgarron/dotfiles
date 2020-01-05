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

# XDG path configuration

    if test -f "$HOME/.config/fish/xdg-basedir-workarounds.fish"
      loading_indicator "xdg-basedir-workarounds"
      source "$HOME/.config/fish/xdg-basedir-workarounds.fish"
    end

# Machines

    set EUCLID Euclid euclid Euclid.local
    set GALOIS Galois galois Galois.local
    set MIRZAKHANI Mirzakhani mirzakhani Mirzakhani.local

# Path

    if contains (hostname -s) $EUCLID
    # Homebrew is first for Python
        set PATH \
            "$HOME/local/brew/bin" \
            $PATH \
            "$HOME/local/bin/misc" \
            "$HOME/local/bin/scripts" \
            "$HOME/local/bin/dance-hacking" \
            "$HOME/Code/depot_tools"
    end

    if contains (hostname -s) $MIRZAKHANI
        set PATH \
            $PATH \
            "$HOME/Code/depot_tools" \
            "$HOME/github/gh-cli/exe/"
    end

    if contains (hostname -s) $GALOIS
        set PATH \
            $PATH \
            "$HOME/local/bin/misc" \
            "$HOME/local/bin/scripts" \
            "$HOME/local/bin/dance-hacking"
    end

# MOTD

    function fish_greeting

      # Based on ANSI Shadow with the shadow removed:
      if contains (hostname -s) $GALOIS
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=Galois%0AGALOIS
        __echo " ██████     █████    ██         ██████    ██   ███████ "
        __echo "██         ██   ██   ██        ██    ██   ██   ██      "
        __echo "██   ███   ███████   ██        ██    ██   ██   ███████ "
        __echo "██    ██   ██   ██   ██        ██    ██   ██        ██ "
        __echo " ██████    ██   ██   ███████    ██████    ██   ███████ "
        __echo ""
      else if contains (hostname -s) $EUCLID
        __echo "███████ ██    ██  ██████ ██      ██ ██████ "
        __echo "██      ██    ██ ██      ██      ██ ██   ██"
        __echo "█████   ██    ██ ██      ██      ██ ██   ██"
        __echo "██      ██    ██ ██      ██      ██ ██   ██"
        __echo "███████  ██████   ██████ ███████ ██ ██████ "
      else if contains (hostname -s) $MIRZAKHANI
        __echo "███    ███ ██ ██████  ███████  █████  ██   ██ ██   ██  █████  ███    ██ ██"
        __echo "████  ████ ██ ██   ██    ███  ██   ██ ██  ██  ██   ██ ██   ██ ████   ██ ██"
        __echo "██ ████ ██ ██ ██████    ███   ███████ █████   ███████ ███████ ██ ██  ██ ██"
        __echo "██  ██  ██ ██ ██   ██  ███    ██   ██ ██  ██  ██   ██ ██   ██ ██  ██ ██ ██"
        __echo "██      ██ ██ ██   ██ ███████ ██   ██ ██   ██ ██   ██ ██   ██ ██   ████ ██"
        __echo ""
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

### Editors

    set -x "EDITOR" "code -w"
    abbr -a c "code"
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

    set STDERRED_PATH "$HOME/local/dylib/libstderred.dylib"
    if test -f "$STDERRED_PATH"
        export DYLD_INSERT_LIBRARIES=""
        # I can't get STDERRED_BLACKLIST to work, so let's make it easy to unset DYLD_INSERT_LIBRARIES
        abbr -a "dy" "set -e DYLD_INSERT_LIBRARIES"
    end

    abbr -a serve "python -m SimpleHTTPServer"

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
        mac-add-shortcut "com.adobe.Lightroom6" "Go to Folder in Library" "@l"
        mac-add-shortcut "org.audacityteam.audacity" "Save Project As…" "\$@s"
        mac-add-shortcut "com.apple.iMovieApp" "File…" "\$@e"
        mac-add-shortcut "com.bloombuilt.dayone-mac" "Paste as Plain Text" "\$@v"
        mac-add-shortcut "com.apple.iWork.Pages" "PDF…" "\$@e"
        mac-add-shortcut "org.audacityteam.audacity" "Zoom Out" "@-"
        mac-add-shortcut "org.audacityteam.audacity" "Zoom In" "@="
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

    if [ "$MANUAL_RELOAD" != "true" ]
        functions -e abbr
    end
    # From now on, reloads of this file are considered "manual".
    set MANUAL_RELOAD true
