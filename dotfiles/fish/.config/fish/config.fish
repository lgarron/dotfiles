# `config.fish`

# Path

    set PATH \
      $PATH \
      "$HOME/local/bin/scripts" \
      "$HOME/local/bin/misc" \
      "$HOME/local/bin/dance-hacking"

set GALOIS = Galois Galois.local
set NOETHER = Noether lgarron-macbookpro

# MOTD

    function fish_greeting

      if contains (hostname -s) $GALOIS
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=Galois%0AGALOIS
        echo " ██████     █████    ██         ██████    ██   ███████ "
        echo "██         ██   ██   ██        ██    ██   ██   ██      "
        echo "██   ███   ███████   ██        ██    ██   ██   ███████ "
        echo "██    ██   ██   ██   ██        ██    ██   ██        ██ "
        echo " ██████    ██   ██   ███████    ██████    ██   ███████ "
        echo ""
      else if contains (hostname -s) $NOETHER
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=NOETHER
        echo "███    ██  ██████  ███████ ████████ ██   ██ ███████ ██████ "
        echo "████   ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        echo "██ ██  ██ ██    ██ █████      ██    ███████ █████   ██████ "
        echo "██  ██ ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        echo "██   ████  ██████  ███████    ██    ██   ██ ███████ ██   ██"
        echo ""
      else
        echo "Welcome to "(hostname -s)
      end

    end

# Shortcuts

## Shell

    abbr -a rc ". $HOME/.config/fish/config.fish"
    abbr -a unset "set -e"

### Editors

    export EDITOR="subl -w"
    abbr -a s "subl"

## Search

    function f
      find . -iname "*$argv[1]*"
    end

    function gre
      grep -ir $argv[1] .
    end

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

    abbr -a serve "python -m SimpleHTTPServer"

    # Technically a private API token, but not critically secret.
    set -x "ECHO_NEST_API_KEY" "EJ7ZVMPNXWVFXS1KE"

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"


## Web

    function https
        http --default-scheme https $argv
    end

    abbr -a "hs" "https -ph"


# Includes

    . $HOME/.config/fish/git.fish

    if test -f $HOME/.config/fish/chrome.fish
        . $HOME/.config/fish/chrome.fish
    end

    if not functions -q iterm_fish_prompt
        if [ $SSH_TTY ]
            source "$HOME/.iterm2_shell_integration.fish"
            function subl
                rmate $argv
            end
        end
    end
