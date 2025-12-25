#!/usr/bin/env bash

set -euo pipefail

# For Codespaces
# https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles

mkdir -p "${HOME}/.config"
test -d "${HOME}/.config/binaries" || git clone --depth=1 https://github.com/lgarron/binaries "${HOME}/.config/binaries"

chmod +x "${HOME}/.config/binaries/linux-x64/"*
export PATH="$PATH:${HOME}/.config/binaries/linux-x64"

touch "${HOME}/.bashrc"
echo "${HOME}/.config/binaries/linux-x64/fish" >> ~/.bashrc


make setup

if [ -n "${CODESPACES:-}" ]
then
  rm -rf \
    "${HOME}/.config/fish/config.fish" \
    "${HOME}/.local/share/fish"
fi
make linux

sudo add-shell "${HOME}/.config/binaries/linux-x64/fish"
sudo chsh "$(id -un)" --shell "${HOME}/.config/binaries/linux-x64/fish"

