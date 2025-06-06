tell application "Music" to activate

on toggleCheckbox(theCheckbox, want)
	tell application "System Events"
		tell process "Music"
			tell theCheckbox
				set checkboxStatus to value of theCheckbox as boolean
				if checkboxStatus is not want then click theCheckbox
			end tell
		end tell
	end tell
end toggleCheckbox

on displayColumn(columnName, want)
	tell application "System Events"
		tell process "Music"
			set theCheckbox to checkbox columnName of scroll area 1 of window "View Options"
			my toggleCheckbox(theCheckbox, want)
		end tell
	end tell
end displayColumn

tell application "System Events"
	tell process "Music"
		if not (exists menu item "as Songs" of menu "View" of menu bar item "View" of menu bar 1) then
			if not (exists window "Music") then
				click menu item "Music" of menu "Window" of menu bar item "Window" of menu bar 1
			end if
			perform action "AXRaise" of window "Music"
			delay 1
		end if
		
		-- "View as Songs", implementation 1
		click menu item "as Songs" of menu "View" of menu bar item "View" of menu bar 1
		
		delay 1
		
		if not (exists window "View Options") then
			click menu item "Show View Options" of menu "View" of menu bar item "View" of menu bar 1
		end if
		
		repeat 4 times
			if not (exists window "View Options") then
				delay 0.5
			end if
		end repeat
		
		-- "View as Songs", implementation 2
		-- Note: the pop up button indexing get depends on what the current view is. We recognize and handle only the default ("Playlist").
		-- In case the view is already "Songs", then this uses the second pop up button (which is confusingly the first indexed one) — which is not the one we want — but we ignore it.
		tell pop up button 1 of window "View Options"
			if value is "Playlist" then
				click
				delay 0.1
				pick menu item "Songs" of menu 1
			end if
		end tell
		
		-- Remove every column (except title), so that we can add them back in the correct order.
		repeat with theCheckbox in (every checkbox of scroll area 1 of window "View Options")
			my toggleCheckbox(theCheckbox, false)
		end repeat
		
		-- Add back columns we want.
		-- This must be done in the order that we want.
		my displayColumn("Time", true)
		my displayColumn("Beats Per Minute", true)
		my displayColumn("Grouping", true)
		my displayColumn("Artist", true)
		my displayColumn("Album", true)
		my displayColumn("Cloud Download", true)
		my displayColumn("Cloud Status", true)
		my displayColumn("Plays", true)
		my displayColumn("Rating", true)
		
		-- Close "View Options"
		-- (`window "View Options"` doesn't understand `close` 🤷)
		click menu item "Close" of menu "File" of menu bar item "File" of menu bar 1
	end tell
end tell
