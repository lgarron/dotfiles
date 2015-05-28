# `config.fish`

# Path

    set PATH /Users/lgarron/Code/depot_tools $PATH

# MOTD

    function fish_greeting
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

# Shortcuts

## Shell

    abbr -a rc ". /Users/lgarron/.config/fish/config.fish"

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

    abbr -a o "open"
    abbr -a xs "xargs subl"

    export DYLD_INSERT_LIBRARIES="/Users/lgarron/local/dylib/libstderred.dylib"


# Includes

    . /Users/lgarron/.config/fish/git.fish
    . /Users/lgarron/.config/fish/chrome.fish
