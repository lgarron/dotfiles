
tell application "System Events"
	tell process "Music"
		-- "View as Songs", implementation 1
		try
			click menu item "Find in Playlist" of menu "View" of menu bar item "View" of menu bar 1
		end try
		try
			click menu item "Find in Songs" of menu "View" of menu bar item "View" of menu bar 1
		end try
	end tell
end tell
