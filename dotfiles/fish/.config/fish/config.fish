# `config.fish`

# Setup

    # Only print if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    function _echo
        if isatty
            echo $argv
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

    set GALOIS = Galois Galois.local
    set NOETHER = Noether lgarron-macbookpro
    set LGARRON1 = lgarron1

# Path

    if contains (hostname -s) $GALOIS
        set PATH \
            $PATH \
            "$HOME/local/bin/misc" \
            "$HOME/local/bin/scripts" \
            "$HOME/local/bin/dance-hacking"
    end

    if contains (hostname -s) $NOETHER
        set PATH \
            "$HOME/local/bin-front-of-path" \
            "/usr/local/git/current/bin" \
            "$HOME/local/homebrew/bin" \
            $PATH \
            "$HOME/local/bin/misc" \
            "$HOME/Code/Work/google-cloud-sdk/bin"
    end

# MOTD

    function fish_greeting

      if contains (hostname -s) $GALOIS
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=Galois%0AGALOIS
        _echo " ██████     █████    ██         ██████    ██   ███████ "
        _echo "██         ██   ██   ██        ██    ██   ██   ██      "
        _echo "██   ███   ███████   ██        ██    ██   ██   ███████ "
        _echo "██    ██   ██   ██   ██        ██    ██   ██        ██ "
        _echo " ██████    ██   ██   ███████    ██████    ██   ███████ "
        _echo ""
      else if contains (hostname -s) $NOETHER
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=NOETHER
        _echo "███    ██  ██████  ███████ ████████ ██   ██ ███████ ██████ "
        _echo "████   ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        _echo "██ ██  ██ ██    ██ █████      ██    ███████ █████   ██████ "
        _echo "██  ██ ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        _echo "██   ████  ██████  ███████    ██    ██   ██ ███████ ██   ██"
        _echo ""
      else if contains (hostname -s) $LGARRON1
        _echo "██       ██████   █████  ██████  ██████   ██████  ███    ██  ██"
        _echo "██      ██       ██   ██ ██   ██ ██   ██ ██    ██ ████   ██ ███"
        _echo "██      ██   ███ ███████ ██████  ██████  ██    ██ ██ ██  ██  ██"
        _echo "██      ██    ██ ██   ██ ██   ██ ██   ██ ██    ██ ██  ██ ██  ██"
        _echo "███████  ██████  ██   ██ ██   ██ ██   ██  ██████  ██   ████  ██"
        _echo ""
      else
        _echo "Welcome to "(hostname -s)
      end

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

    abbr -a xs "xargs subl"

    export DYLD_INSERT_LIBRARIES="$HOME/local/dylib/libstderred.dylib"
    # I can't get STDERRED_BLACKLIST to work, so let's make it easy to unset DYLD_INSERT_LIBRARIES
    abbr -a "dy" "set -e DYLD_INSERT_LIBRARIES"

    abbr -a serve "python -m SimpleHTTPServer"

    # Technically a private API token, but not critically secret.
    set -x "_ECHO_NEST_API_KEY" "EJ7ZVMPNXWVFXS1KE"

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

    set -x "DANCE_HACKING_MUSIC_FOLDER" "$HOME/Temporary/Music/"

    function aedeploy
      _echo "Invoking wrapped aedeploy."
      env DYLD_INSERT_LIBRARIES='' command aedeploy $argv
    end

## Web

    function https
        http --default-scheme https $argv
    end

    # *h*ttps *h*eaders
    abbr -a "hh" "https -ph"

## iTerm

    # In case we need to set this on on a machine from scratch.
    function install_iterm_shell_integration
      curl -L "https://iterm2.com/misc/install_shell_integration.sh" | bash
    end

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

    if contains (hostname -s) $LGARRON1
      if [ $SSH_TTY ]

        function subl
            rmate $argv
        end
        set -x "EDITOR" "rmate -w"

        set -x "DISPLAY" ":20"

      end
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
