#!/opt/homebrew/bin/fish --no-config --

# TODO: dedupe with `path.fish`
set PATH \
    "$HOME/.local/share/cargo/bin" \
    /opt/homebrew/bin \
    "$HOME/.local/share/gopath/bin" \
    $HOME/.cache/.bun/bin \
    /usr/local/bin \
    $PATH

source /Users/lgarron/Code/git/github.com/lgarron/dotfiles/dotfiles/xdg-basedir-workarounds/.config/fish/xdg-basedir-workarounds.fish

$argv
