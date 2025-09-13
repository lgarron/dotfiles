#!/usr/bin/env -S fish --no-config

osascript -e '
tell application "Finder"
	mount volume "smb://Pythagoras-ts.wyvern-climb.ts.net/Trenzalore"
	mount volume "smb://Pythagoras-ts.wyvern-climb.ts.net/Trenzalore CRM Videos"
end tell'

terminal-notifier \
    -title "Mount Trenzalore drives (Tailscale)" \
    -message "Mounted successfully" \
    -execute "reveal-macos "(string escape /Volumes/Trenzalore/)
