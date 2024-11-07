#!/usr/bin/env -S fish --no-config

ffmpeg \
  -i $argv[2] \
  -itsscale 0.25 \
  -i $argv[1] \
  -c:v copy \
  -c:a copy \
  $argv[1]".120hz.mov"

hevc --force-bit-depth 10 $argv[1]".120hz.mov"
