#!/usr/bin/env -S fish --no-config

ffmpeg \
  -i $argv[2] \
  -i $argv[1] \
  -c:v copy \
  -filter:a "atempo=0.5,atempo=0.5" \
  $argv[1]".25%-slow-mo.mov"

hevc --force-bit-depth 10 $argv[1]".25%-slow-mo.mov"
