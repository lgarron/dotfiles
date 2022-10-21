tell application "Music"
	activate
end tell
tell application "System Events"
	tell process "Music"
		tell menu bar 1
			tell menu bar item "Controls"
				tell menu "Controls"
					click menu item "Go to Current Song"
				end tell
			end tell
		end tell
	end tell
end tell
return true
