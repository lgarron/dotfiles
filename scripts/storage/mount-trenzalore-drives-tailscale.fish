#!/usr/bin/env -S fish --no-config

osascript -e '
tell application "Finder"
	mount volume "smb://Pythagoras.local/Trenzalore"
	mount volume "smb://Pythagoras.local/Trenzalore CRM Videos"
end tell'

terminal-notifier \
    -title "Mount Trenzalore drives (Tailscale)" \
    -message "Mounted successfully" \
    -execute "reveal-macos "(string escape /Volumes/Trenzalore/)
