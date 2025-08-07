#!/usr/bin/env -S fish --no-config

osascript -e '
tell application "Finder"
	mount volume "smb://Pythagoras.tlb/Trenzalore"
	mount volume "smb://Pythagoras.tlb/Trenzalore CRM Videos"
end tell'

terminal-notifier \
    -title "Mount Trenzalore drives (local)" \
    -message "Mounted successfully" \
    -execute "reveal-macos "(string escape /Volumes/Trenzalore/)
