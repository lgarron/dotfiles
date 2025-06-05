# `config.fish`

# Setup

    # Only load the config if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    if not status is-interactive
      exit 0
    end

# Codespaces workaround

    # Codespaces ships an outdated `fish` by default. The easiest way to get the
    # interactive shell to use the correct `fish` is to invoke it ourselves
    # here.
    if echo $FISH_VERSION | grep "^3" > /dev/null
      if test -f $HOME/.config/binaries/linux-x64/fish
        $HOME/.config/binaries/linux-x64/fish
        exit
      end
    end

# Path

    source $HOME/.config/fish/path.fish

# Loading

    if [ "$_FISH_MANUAL_RELOAD" = "true" ]
      echo "🐟🔄 Resetting all abbreviations."
      echo ""
      abbr --erase (abbr --list)

      echo "🐟🔄 Reloading "(set_color --bold)"fish"(set_color normal)" files."
      echo "↪ 🐟 "(status --current-filename)
    end

    function _load_or_fail_dotfile_import
      set -l file $HOME/.config/fish/$argv[1].fish
      if [ "$_FISH_MANUAL_RELOAD" = "true" ]
        echo "  ↪ 🐟 $file"
      end
      source $file
    end

# Imports

    _load_or_fail_dotfile_import "greeting"

    _load_or_fail_dotfile_import "xdg-basedir-workarounds"
    _load_or_fail_dotfile_import "abbr"

    _load_or_fail_dotfile_import "abbreviations"
    _load_or_fail_dotfile_import "bindings"
    _load_or_fail_dotfile_import "git"
    _load_or_fail_dotfile_import "jj"
    _load_or_fail_dotfile_import "dev"
    _load_or_fail_dotfile_import "cd-dir"
    _load_or_fail_dotfile_import "tee"

# Shortcuts

## Shell

    function mkcd
      mkdir $argv[1] && cd $argv[1]
    end

### Abbrevation definition helpers

### Editors

    # TODO: https://github.com/microsoft/vscode/issues/139634
    set -xg "VISUAL" (command -v code)" -w --"
    set -xg "EDITOR" (command -v code)" -w --"

# Theme

    # Restore blue color for commands.
    set -g fish_color_command blue

# Cleanup

    # From now on, reloads of this file are considered "manual".
    set _FISH_MANUAL_RELOAD true
