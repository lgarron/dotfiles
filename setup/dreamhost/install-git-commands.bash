#!/usr/bin/env bash

set -euo pipefail

function install-git-freeze-bin {
  bin=${1}
  echo "Installing: ${bin}"
  curl -o "/tmp/${bin}" "https://raw.githubusercontent.com/lgarron/git-freeze/main/bin/${bin}"
  cp "/tmp/${bin}" "$HOME/.shared-hosting/bin/${bin}"
  chmod +x "$HOME/.shared-hosting/bin/${bin}"
}

command -v git-freeze || install-git-freeze-bin git-freeze
command -v git-thaw || install-git-freeze-bin git-thaw
command -v git-abandon || install-git-freeze-bin git-abandon
