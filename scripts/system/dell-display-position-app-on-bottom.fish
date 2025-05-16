#!/usr/bin/env -S fish --no-config


# TODO: AppleScript's quoting almost certainly does not line up with `fish`, so there's probably an injection.
# Perhaps limit to ASCII for now?
set QUOTED_PROCESS '"'(string escape --no-quoted --style=script $argv[1])'"'

# TODO: actually detect displays
osascript -e '
tell application "Image Events"
    launch
        set numDisplays to count displays
    quit
end tell

if numDisplays is greater than 1
    tell application "System Events"
        tell process '$QUOTED_PROCESS'
            set frontmost to true
            repeat 10 times
                set theWindows to get windows
                if theWindows is not {} then
                    exit repeat
                end if
                delay 0.2
            end repeat

            tell window 1
                set size to {1080, 947}
                set position to {-1080, 973}
            end tell
        end tell
    end tell
end if
'
