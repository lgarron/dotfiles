#!/usr/bin/env -S bash --

set -euo pipefail

# For Codespaces
# https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles

mkdir -p "${HOME}/.local/share"
test -d "${HOME}/.local/share/binaries" || git clone --depth=1 https://github.com/lgarron/binaries "${HOME}/.local/share/binaries"

chmod +x "${HOME}/.local/share/binaries/linux-x64/"*
export PATH="$PATH:${HOME}/.local/share/binaries/linux-x64"

# We have enough now to launch into `fish`.
./setup/linux/bootstrap.fish
