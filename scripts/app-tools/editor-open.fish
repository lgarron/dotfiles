#!/usr/bin/env -S fish --no-config

set PATH_UTF8 (printf %s $argv[1] | iconv -f "UTF-8" -t "ISO-8859-1")
set REALPATH (realpath $PATH_UTF8)
set PREFIX "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/"
if string match "$PREFIX*" $REALPATH
  set OBSIDIAN_NOTE_PATH (string replace "$PREFIX" "" $REALPATH)
  set ENCODED_OBSIDIAN_NOTE_PATH (jq -rn --arg x $OBSIDIAN_NOTE_PATH "\$x|@uri")
  open -a "Obsidian" "obsidian://open?vault=Documents&file=$ENCODED_OBSIDIAN_NOTE_PATH"
else
  open -a "Visual Studio Code" $PATH_UTF8
end

return 1 # To avoid showing results in Quicksilver
