#!/usr/bin/env bash

set -euo pipefail

# This file cannot have a `.bash` extension, but I would like all `bash` code to
# live in `.bash` files. So we wrap a file in a more appropriate place.
./setup/linux/bootstrap.bash
