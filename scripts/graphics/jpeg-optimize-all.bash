#!/bin/bash

if [[ "$PWD" = "$HOME" ]]
then
  echo "Current dir is \$HOME. This is probably due to a race condition or tab mixup. Aborting."
  exit -1
fi

# -0: goes with print0
# -P: maxprocs
# -n: each arg gets its own invocation
find . -print0 -iname "*.jpg" \
  | xargs \
    -0 \
    -P 4 \
    -n 1 \
    jpeg-optimize
