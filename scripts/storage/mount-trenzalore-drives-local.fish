#!/usr/bin/env -S fish --no-config --

osascript -e '
tell application "Finder"
	mount volume "smb://Pythagoras.lan/Trenzalore"
	mount volume "smb://Pythagoras.lan/Trenzalore CRM Videos"
end tell'

terminal-notifier \
    -title "Mount Trenzalore drives (local)" \
    -message "Mounted successfully" \
    -execute "/opt/homebrew/bin/reveal-macos "(string escape /Volumes/Trenzalore/)
