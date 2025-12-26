#!/usr/bin/env -S bash --

set -euo pipefail

DIRNAME=$(dirname "${0}")
cd "${DIRNAME}"

# This file cannot have a `.bash` extension, but I would like all `bash` code to
# live in `.bash` files. So we wrap a file in a more appropriate place.
./setup/linux/bootstrap.bash
