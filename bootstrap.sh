#!/usr/bin/env bash

set -euo pipefail

# For Codespaces
# https://docs.github.com/en/codespaces/customizing-your-codespace/personalizing-github-codespaces-for-your-account#dotfiles

if ! command -v stow
then
  echo "Installing \`stow\`."
  sudo add-apt-repository --yes http://archive.ubuntu.com/ubuntu/ || echo "🤷" # *sigh* https://askubuntu.com/a/1132852 # TODO: Make this more portable across Debian OSes.
  sudo apt-get install -y stow

  # Note: we would install `fish` together with `stow`, but most default PPAs are 3 years of date. So we don't even bother, and handle `fish` separately below.
fi

function install_fish_3_6_or_higher {
  echo "Installing updated \`fish\` for updated abbreviation support."

  sudo apt-add-repository ppa:fish-shell/release-3
  sudo apt update
  sudo apt install --yes fish
}

if command -v fish
then
  echo "\`fish\` detected… testing if we're before version 3.6"
  fish --version | grep "3.[012345]" && install_fish_3_6_or_higher
else
  echo "No \`fish\` detected."
  install_fish_3_6_or_higher
fi

if [ -n "$CODESPACES" ]
then
  rm -rf \
    ~/.config/fish/config.fish \
    ~/.local/share/fish || rm -rf \
    ~/.config/fish/config.fish \
    ~/.local/share/fish
fi
make linux

sudo chsh "$(id -un)" --shell "$(command -v fish)"

./setup/bootstrap/install-git-commands
./setup/bootstrap/install-lgarron-scripts
./setup/bootstrap/install-mak
