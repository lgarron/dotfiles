# `config.fish`

# Setup

    # Only print if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    if not status is-interactive
      exit 0
    end

# fish 4.0 experimentation for token nav

    echo -n -e "\r"
    echo "🐟🧪 version: "$FISH_VERSION

# Path

    source $HOME/.config/fish/path.fish

# Loading

    function _echo_manual_reload
      if [ "$_FISH_MANUAL_RELOAD" = "true" ]
        echo $argv[1]
      end
    end

    function load_or_fail
      _echo_manual_reload "  ↪ 🐟 $argv[1]"
      source $argv[2]
    end

    _echo_manual_reload "🐟🔄 Reloading "(set_color --bold)"fish"(set_color normal)" files."
    _echo_manual_reload "↪ 🐟 "(status --current-filename)

# XDG path configuration

    load_or_fail "greeting" $HOME/.config/fish/greeting.fish

    load_or_fail "xdg-basedir-workarounds" $HOME/.config/fish/xdg-basedir-workarounds.fish
    load_or_fail "abbr" $HOME/.config/fish/abbr.fish

    load_or_fail "abbreviations" $HOME/.config/fish/abbreviations.fish
    load_or_fail "git" $HOME/.config/fish/git.fish
    load_or_fail "dev" $HOME/.config/fish/dev.fish
    load_or_fail "cd-dir" $HOME/.config/fish/cd-dir.fish
    if test -f $HOME/Code/git/github.com/lgarron/repo/repo_completions_and_abbreviations.fish
      load_or_fail "repo" $HOME/Code/git/github.com/lgarron/repo/repo_completions_and_abbreviations.fish # TODO: configure this load statically
    end

# Shortcuts

## Shell

    function mkcd
      mkdir $argv[1]
      cd $argv[1]
    end

### Abbrevation definition helpers

### Editors

    # TODO: https://github.com/microsoft/vscode/issues/139634
    set -xg "VISUAL" (command -v code)" -w --"
    set -xg "EDITOR" (command -v code)" -w --"
    # set -xg EDITOR "open -b com.microsoft.VSCode"

## General

    # abbr -a t "tee >(pbcopy)"
    function 📋
      cat > /tmp/pbcopy.txt
      cat /tmp/pbcopy.txt
      cat /tmp/pbcopy.txt | pbcopy
      rm /tmp/pbcopy.txt
    end
    abbr -a t "📋"

    function o
      if [ (count $argv) = 0 ]
        open .
      else
        open $argv
      end
    end

# Cleanup

    _echo_manual_reload ""
    functions -e _echo_manual_reload

    # From now on, reloads of this file are considered "manual".
    set _FISH_MANUAL_RELOAD true
