tell application "Google Chrome"
	activate
end tell

tell application "System Events" to tell process "Google Chrome"
	click menu item "Screenshot" of menu "Profiles" of menu bar item "Profiles" of menu bar 1
end tell