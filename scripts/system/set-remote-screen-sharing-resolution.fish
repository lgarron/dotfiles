#!/usr/bin/env -S fish --no-config

# Set the remote screen sharing resolution for a given computer automatically.
# Hardcoded to a 5K monitor and the 16-inch MacBook Pro.

if [ (count $argv) -gt 0 ]
    set REMOTE $argv[1]
    set CURRENT_RESOLUTION (betterdisplaycli get --displayWithMainStatus --resolution)
    if contains -- 2560x1440 $CURRENT_RESOLUTION
        nohup ssh $REMOTE 'betterdisplaycli set --name="LG UltraFine" --connected=off ; betterdisplaycli set --name="Screen Sharing" --resolution="2560x1440"' &
        disown
    else
        nohup ssh $REMOTE 'betterdisplaycli set --name="LG UltraFine" --connected=off ; betterdisplaycli set --name="Screen Sharing" --resolution="1728x1080"' &
        disown
    end
else
    echo "Please specify a remote server."
end
