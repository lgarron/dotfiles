#!/opt/homebrew/bin/fish --no-config --

set -gx _FISH_TRAMPOLINE true

source /Users/lgarron/Code/git/github.com/lgarron/dotfiles/dotfiles/fish/.config/fish/path.fish
source /Users/lgarron/Code/git/github.com/lgarron/dotfiles/dotfiles/xdg-basedir-workarounds/.config/fish/xdg-basedir-workarounds.fish

$argv
