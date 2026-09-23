#!/usr/bin/env osascript

tell application "System Events" to tell process "gg"
	click menu item "Reopen" of menu "Repository" of menu bar 1
end tell
