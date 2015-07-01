# `config.fish`

# Path

    set PATH \
      $PATH \
      "$HOME/local/bin/scripts" \
      "$HOME/local/bin/misc" \
      "$HOME/local/bin/dance-hacking"

# MOTD

    function fish_greeting

      if [ (hostname) = "Galois" or (hostname) = "Galois.local" ]
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=Galois%0AGALOIS
        echo ""
        echo " ██████     █████    ██         ██████    ██   ███████ "
        echo "██         ██   ██   ██        ██    ██   ██   ██      "
        echo "██   ███   ███████   ██        ██    ██   ██   ███████ "
        echo "██    ██   ██   ██   ██        ██    ██   ██        ██ "
        echo " ██████    ██   ██   ███████    ██████    ██   ███████ "
        echo ""
      end

      if [ (hostname) = "Noether" ]
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=NOETHER
        echo ""
        echo "███    ██  ██████  ███████ ████████ ██   ██ ███████ ██████ "
        echo "████   ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        echo "██ ██  ██ ██    ██ █████      ██    ███████ █████   ██████ "
        echo "██  ██ ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        echo "██   ████  ██████  ███████    ██    ██   ██ ███████ ██   ██"
        echo ""
      end

    end

# Shortcuts

## Shell

    abbr -a rc ". $HOME/.config/fish/config.fish"

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
    abbr -a t "cat > /tmp/pbcopy.txt; and cat /tmp/pbcopy.txt ; and cat /tmp/pbcopy.txt | pbcopy; and rm /tmp/pbcopy.txt"

    function o
        if [ (count $argv) = 0 ]
            open .
        else
            open $argv
        end
    end

    abbr -a xs "xargs subl"

    export DYLD_INSERT_LIBRARIES="$HOME/local/dylib/libstderred.dylib"


# Includes

    . $HOME/.config/fish/git.fish

    if [ (hostname) != "Galois" ]
        . $HOME/.config/fish/chrome.fish
    end

    source "$HOME/.iterm2_shell_integration.fish"
