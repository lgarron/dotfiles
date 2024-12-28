# `config.fish`

# Setup

    # Only load the config if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    if not status is-interactive
      exit 0
    end

# Path

    source $HOME/.config/fish/path.fish

    # Workaround for https://github.com/zellij-org/zellij/issues/3708
    if string match --entire -- (uname) "Darwin" > /dev/null
      if not set -q TMPDIR
        set -x TMPDIR (dirname (mktemp))
      end
    end

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
    load_or_fail "bindings" $HOME/.config/fish/bindings.fish
    load_or_fail "git" $HOME/.config/fish/git.fish
    load_or_fail "dev" $HOME/.config/fish/dev.fish
    load_or_fail "cd-dir" $HOME/.config/fish/cd-dir.fish

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
      # TODO: pipe?
      set -l TEMP_FILE (mktemp -t "pbcopy")
      cat > $TEMP_FILE
      cat $TEMP_FILE
      cat $TEMP_FILE | pbcopy
      rm $TEMP_FILE
    end
    abbr -a t "📋"

    function tt
      if set SHELL_PASTEBOARD_FILE
        rm -f $_FISH_SHELL_PASTEBOARD_FILE
      end
      set -gx _FISH_SHELL_PASTEBOARD_FILE (mktemp -t "pasteboard")
      cat > $_FISH_SHELL_PASTEBOARD_FILE
      cat $_FISH_SHELL_PASTEBOARD_FILE
    end
    function tt_paste
      set -l cmd (commandline -op)
      if [ (count $cmd) -lt 2 ]
        return 1
      end
      cat $_FISH_SHELL_PASTEBOARD_FILE
    end
    abbr -a tt --position anywhere --function tt_paste

    function o
      if [ (count $argv) = 0 ]
        open .
      else
        open $argv
      end
    end

# Theme

    # Restore blue color for commands.
    set -g fish_color_command blue

# Cleanup

    _echo_manual_reload ""
    functions -e _echo_manual_reload

    # From now on, reloads of this file are considered "manual".
    set _FISH_MANUAL_RELOAD true
