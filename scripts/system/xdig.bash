#!/bin/bash

# Wrapper for `dig` that allows using `~/.config/dig/digrc` (XDG dir convention compatible) instead of `.digrc`, with reasonable fidelity.

set -euo pipefail

ARGS=$(cat ~/.config/dig/digrc || echo "")
echo "${ARGS}" "$@" | xargs dig
