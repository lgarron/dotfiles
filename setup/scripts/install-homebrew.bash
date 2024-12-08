#!/usr/bin/env bash

if command -v brew
then
  echo "Homebrew already installed. Skipping install…"
  exit 0
fi

echo "Installing Homebrew…"

# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

mkdir -p /opt/homebrew/Library/Taps/lgarron
rm /opt/homebrew/Library/Taps/lgarron/homebrew-lgarron
ln -s \
  /Users/lgarron/Code/git/github.com/lgarron/dotfiles \
  /opt/homebrew/Library/Taps/lgarron/homebrew-lgarron

/opt/homebrew/bin/brew tap oven-sh/bun
