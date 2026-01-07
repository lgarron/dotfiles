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
if echo $FISH_VERSION | grep "^3" >/dev/null
    if test -f $HOME/.local/share/binaries/linux-x64/fish
        $HOME/.local/share/binaries/linux-x64/fish
        exit
    end
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

_load_or_fail_dotfile_import greeting

_load_or_fail_dotfile_import xdg-basedir-workarounds
_load_or_fail_dotfile_import abbr

_load_or_fail_dotfile_import abbreviations
_load_or_fail_dotfile_import bindings
_load_or_fail_dotfile_import git
_load_or_fail_dotfile_import jj
_load_or_fail_dotfile_import dev
_load_or_fail_dotfile_import cd-dir
_load_or_fail_dotfile_import tee

# Shortcuts

## Shell

function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

function _fish_strings_are_identical
    string match --quiet --entire -- $argv[1] $argv[2]
end

function _fish_is_true
    _fish_strings_are_identical $argv[1] true
end

### Abbrevation definition helpers

### Editors

# TODO: https://github.com/microsoft/vscode/issues/139634
set -xg VISUAL (command -v code)" --wait --"
set -xg EDITOR (command -v code)" --wait --"

if not functions --query __builtin_edit_command_buffer
    # The `__builtin_edit_command_buffer` implementation is self-contained (as of 2025-11-04), so this preserves semantics.
    functions --copy edit_command_buffer __builtin_edit_command_buffer
    # Workaround for https://github.com/fish-shell/fish-shell/issues/11966
    function edit_command_buffer
        set -x VISUAL (command -v code)
        __builtin_edit_command_buffer
    end
end

# Theme

# Restore blue color for commands.
set -g fish_color_command blue --bold

# Cleanup

# From now on, reloads of this file are considered "manual".
set _FISH_MANUAL_RELOAD true
