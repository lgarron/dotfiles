#!/opt/homebrew/bin/fish --no-config --

# TODO: dedupe with `path.fish`
set PATH \
  "$HOME/.local/share/cargo/bin" \
  /opt/homebrew/bin \
  /home/linuxbrew/.linuxbrew/bin \
  /home/linuxbrew/.linuxbrew/sbin \
  "$HOME/.local/share/gopath/bin" \
  $HOME/.cache/.bun/bin \
  "/usr/local/bin" \
  "$HOME/.config/binaries/linux-x64" \
  $PATH

source /Users/lgarron/Code/git/github.com/lgarron/dotfiles/dotfiles/xdg-basedir-workarounds/.config/fish/xdg-basedir-workarounds.fish

$argv
