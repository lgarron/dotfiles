#!/opt/homebrew/bin/fish --no-config --

set -x _FISH_USER_PATHS_QUIET_SETUP true
source /Users/lgarron/Code/git/github.com/lgarron/dotfiles/dotfiles/fish/.config/fish/path.fish

source /Users/lgarron/Code/git/github.com/lgarron/dotfiles/dotfiles/xdg-basedir-workarounds/.config/fish/xdg-basedir-workarounds.fish

$argv
