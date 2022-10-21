tell application "Google Chrome"
	activate
end tell

try
	tell application "System Events" to tell process "Google Chrome"
		click menu item "Development" of menu "Profiles" of menu bar item "Profiles" of menu bar 1
	end tell
end try
