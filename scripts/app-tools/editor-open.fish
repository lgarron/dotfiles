#!/usr/bin/env -S fish --no-config

set REALPATH (realpath $argv[1])
set PREFIX "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/"
if string match "$PREFIX*" $REALPATH
  set OBSIDIAN_NOTE_PATH (string replace "$PREFIX" "" $REALPATH)
  set ENCODED_OBSIDIAN_NOTE_PATH (jq -rn --arg x $OBSIDIAN_NOTE_PATH "\$x|@uri")
  open -a "Obsidian" "obsidian://open?vault=Documents&file=$ENCODED_OBSIDIAN_NOTE_PATH"
else
  open -a "Visual Studio Code" $argv[1]
end

return 1 # To avoid showing results in Quicksilver
