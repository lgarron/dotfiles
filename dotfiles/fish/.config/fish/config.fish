# `config.fish`

# Setup

# Only load the config if we're a TTY.
# This prevents `protocol error: bad line length character` in git.
if not status is-interactive
    exit 0
end

# Path

source $HOME/.config/fish/path.fish

# `$DOTFILES_FOLDER`

# TODO: check against `realpath` of the current file?
set -x DOTFILES_FOLDER "$HOME/Code/git/github.com/lgarron/dotfiles"
if [ "$CODESPACES" = true ]
    set DOTFILES_FOLDER "/workspaces/.codespaces/.persistedshare/dotfiles"
end

# Loading

if [ "$_FISH_MANUAL_RELOAD" = true ]
    echo "🐟🔄 Resetting all abbreviations."
    echo ""
    abbr --erase (abbr --list)

    echo "🐟🔄 Reloading "(set_color --bold)"fish"(set_color normal)" files."
    echo "↪ 🐟 "(status --current-filename)
end

function _load_or_fail_dotfile_import
    set -l file $HOME/.config/fish/$argv[1].fish
    if [ "$_FISH_MANUAL_RELOAD" = true ]
        echo "  ↪ 🐟 $file"
    end
    source $file
end

# Imports

_load_or_fail_dotfile_import xdg-basedir-workarounds

_load_or_fail_dotfile_import abbreviations
_load_or_fail_dotfile_import bindings
_load_or_fail_dotfile_import git
_load_or_fail_dotfile_import jj
_load_or_fail_dotfile_import dev
_load_or_fail_dotfile_import commandline

### Abbrevation definition helpers

### Editors

# TODO: https://github.com/microsoft/vscode/issues/139634
set -xg VISUAL (command -v code)" --wait --"
set -xg EDITOR (command -v code)" --wait --"

# Theme

# Restore blue color for commands.
set -g fish_color_command blue --bold

# Cleanup

# From now on, reloads of this file are considered "manual".
set _FISH_MANUAL_RELOAD true
