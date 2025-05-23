#!/usr/bin/env bash

set -euo pipefail

# For Codespaces
# https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles

mkdir -p "${HOME}/.config"
test -d "${HOME}/.config/binaries" || git clone --depth=1 https://github.com/lgarron/binaries "${HOME}/.config/binaries"

chmod +x "${HOME}/.config/binaries/linux-x64/"*
export PATH="$PATH:${HOME}/.config/binaries/linux-x64"

make setup

if [ -n "${CODESPACES:-}" ]
then
  rm -rf \
    ~/.config/fish/config.fish \
    ~/.local/share/fish
fi
make linux

sudo chsh "$(id -un)" --shell "${HOME}/.config/binaries/linux-x64/fish"

echo yes | "${HOME}/.config/binaries/linux-x64/fish" --install
