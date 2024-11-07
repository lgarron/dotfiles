#!/usr/bin/env -S fish --no-config

if test (count $argv) -lt 1
  echo "Usage: web-app-images icon-source.png"
  return 1
end
set input $argv[1]
set output_prefix (path change-extension "" $input)
set temp_dir (mktemp -d)
square 16 $input $temp_dir/$output_prefix.16px.png
square 32 $input $temp_dir/$output_prefix.32px.png
convert $temp_dir/$output_prefix.16px.png $temp_dir/$output_prefix.32px.png $output_prefix.favicon.ico
echo "$output_prefix.favicon.ico"
square 256 $input $output_prefix.app-icon.png
echo "$output_prefix.app-icon.png"
resize 1200 630 $input $output_prefix.social-media-preview.png
echo "$output_prefix.social-media-preview.png"
