#!/usr/bin/env -S fish --no-config

if test (count $argv) -lt 2
  echo "Usage: resize 512 in.png [out.png]"
  return 1
end
resize $argv[1] $argv[1] $argv[2] $argv[3]
