#!/usr/bin/env bash

set -euo pipefail

# For Codespaces
# https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles

mkdir -p "${HOME}/.config"
git clone https://github.com/lgarron/binaries "${HOME}/.config/binaries"

chmod +x "${HOME}/.config/binaries/linux-x86/"*
export PATH="$PATH:${HOME}/.config/binaries/linux-x86"

echo "Path: $PATH"
command -v stow

if [ -n "$CODESPACES" ]
then
  rm -rf \
    ~/.config/fish/config.fish \
    ~/.local/share/fish
fi
make linux

sudo chsh "$(id -un)" --shell "$(command -v fish)"

echo "<code>"
ls /vscode/bin/linux-x64/*/bin/remote-cli/code
echo "</code>"
