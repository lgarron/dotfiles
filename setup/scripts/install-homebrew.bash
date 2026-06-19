#!/usr/bin/env -S bash --

set -euo pipefail

if command -v brew
then
  echo "Homebrew already installed. Skipping install…"
  exit 0
fi

echo "Installing Homebrew…"

# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# TODO: move this into Brewfiles
/opt/homebrew/bin/brew tap lgarron/lgarron
/opt/homebrew/bin/brew trust lgarron/lgarron
/opt/homebrew/bin/brew tap oven-sh/bun
/opt/homebrew/bin/brew trust --formula oven-sh/bun/bun
/opt/homebrew/bin/brew tap cubing/cubing
/opt/homebrew/bin/brew trust cubing/cubing
/opt/homebrew/bin/brew tap teamookla/speedtest
/opt/homebrew/bin/brew trust --formula teamookla/speedtest/speedtest
/opt/homebrew/bin/brew tap jurplel/tap
/opt/homebrew/bin/brew trust --cask jurplel/tap/instant-space-switcher
/opt/homebrew/bin/brew tap waydabber/betterdisplay
/opt/homebrew/bin/brew trust --formula waydabber/betterdisplay/betterdisplaycli
