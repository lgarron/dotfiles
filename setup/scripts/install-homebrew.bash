#!/usr/bin/env bash

if command -v brew
then
  echo "Homebrew already installed. Skipping install…"
  exit 0
fi

echo "Installing Homebrew…"

# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

/opt/homebrew/bin/brew tap lgarron/lgarron
/opt/homebrew/bin/brew tap oven-sh/bun
