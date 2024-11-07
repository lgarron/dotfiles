#!/usr/bin/env -S fish --no-config

set REALPATH (realpath $argv[1])
if string match "$HOME/Dropbox (Maestral)/*" $REALPATH
    set DROPBOX_PATH (string replace "$HOME/Dropbox (Maestral)/" "" $REALPATH)
    set URL "https://www.dropbox.com/home/$DROPBOX_PATH"
    echo -- "[Opening URL]"
    set_color --bold blue
    echo -- $URL
    set_color normal
    open -- $URL
else
    echo "Not in the Maestral Dropbox folder: $REALPATH"
end
