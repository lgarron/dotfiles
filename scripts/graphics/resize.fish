#!/usr/bin/env -S fish --no-config

if test (count $argv) -lt 3
  echo "Usage: resize 1200 630 in.png [out.png]"
  return 1
end
if test (count $argv) -lt 4
  set output (path change-extension "" $argv[3]).$argv[1]x$argv[2].png
  echo "Writing to: $output"
else
  set output $argv[4]
end
convert $argv[3] -background transparent -trim -gravity Center -extent $argv[1]:$argv[2]\# -scale $argv[1]x$argv[2] $output
