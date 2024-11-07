#!/usr/bin/env -S fish --no-config

set target_folder (echo $argv[1] |
  sed -E "s/[0-9]((\.bmp)?\.png)/_\1/g" |
  sed -E "s/[0-9]_((\.bmp)?\.png)/__\1/g" |
  sed -E "s/[0-9]__((\.bmp)?\.png)/___\1/g" |
  sed -E "s/[0-9]___((\.bmp)?\.png)/____\1/g" |
  sed -E "s/[0-9]____((\.bmp)?\.png)/_____\1/g"
)
mkdir $target_folder
mv $argv $target_folder
ffmpeg \
  -pattern_type glob \
  -i "$target_folder/*.png" \
  -vcodec libx264 \
  -crf 18 \
  -pix_fmt yuv420p \
  $target_folder.zip.mp4
zip -r $target_folder.zip $target_folder
open -R $target_folder.zip $target_folder
