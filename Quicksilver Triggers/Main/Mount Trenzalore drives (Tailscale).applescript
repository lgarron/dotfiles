tell application "Finder"
	mount volume "smb://Pythagoras-ts.wyvern-climb.ts.net/Trenzalore"
	mount volume "smb://Pythagoras-ts.wyvern-climb.ts.net/Trenzalore CRM Videos"
end tell

shell("/opt/homebrew/bin/reveal-macos /Volumes/Trenzalore/")
