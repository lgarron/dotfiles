#!/usr/bin/env -S fish --no-config

set INPUT_ARG $argv[1]

if test ! -d "$INPUT_ARG"
  set SCRIPT_NAME (basename (status -f))
  echo "Usage: $SCRIPT_NAME /path/to-folder"
  echo ""
  echo "This script is useful for making an archived folder much faster for backup/sync programs if it:"
  echo "- contains a lot of small files"
  echo "- rarely needs updates"
  echo ""
  echo "This is is because it can often be faster to transfer several GB than list 100,000 files."
  exit
end

set INPUT_FOLDER (string trim --right --chars=/ $argv[1])
set BASENAME (basename $INPUT_FOLDER)
set OUTPUT_DMG "$INPUT_FOLDER (readonly archive).dmg"

echo "[From] $INPUT_FOLDER"
echo "[To]   $OUTPUT_DMG"
echo ""

hdiutil create \
  -fs apfs \
  -srcfolder "$INPUT_FOLDER" \
  -volname "$BASENAME" \
  "$OUTPUT_DMG"

chmod -w "$OUTPUT_DMG"
