#!/usr/bin/env bash

set -euo pipefail

# For Codespaces
# https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles

mkdir -p "${HOME}/.config"
test -d "${HOME}/.config/binaries" || git clone --depth=1 https://github.com/lgarron/binaries "${HOME}/.config/binaries"

chmod +x "${HOME}/.config/binaries/linux-x64/"*
export PATH="$PATH:${HOME}/.config/binaries/linux-x64"

# We have enough now to launch into `fish`.
./setup/linux/bootstrap.fish
