#!/usr/bin/env -S fish --no-config

osascript -e '
tell application "Finder"
	mount volume "smb://Gallifrey/Pythagoras Arq Germain"
end tell'
