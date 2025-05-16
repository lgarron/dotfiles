tell application "System Events"
	-- TODO: why can't we place this inside a function?
	-- TODO: why can't we get `frontmost` from the query after making it?
	set theFrontmost to the application processes whose name is "BambuStudio" and frontmost is true
	if theFrontmost is {} then
		set manyProcesses to the application processes whose name is "BambuStudio"
		if manyProcesses is {} then
			tell application "BambuStudio" to launch
			
			repeat 20 times
				set theProcesses to application processes whose name is "BambuStudio"
				if theProcesses is not {} then
					exit repeat
				end if
				delay 0.5
			end repeat
			
			tell process "BambuStudio"
				set frontmost to true
				repeat 20 times
					set theWindows to get windows
					if theWindows is not {} then
						exit repeat
					end if
					delay 0.5
				end repeat
			end tell
			
			set theProcess to the first item of theProcesses
		else
			set theProcess to the first item of manyProcesses
		end if
	else
		set theProcess to the first item of theFrontmost
	end if
	
	tell theProcess
		-- Try to avoid a flash of unsized window.
		set frontmost to false
		-- We would add a delay or check here to make sure the application is actually no longer frontmost, but I don't know of any way to avoid UI lag.
		tell window 1
		-- We move the landscape temporarily screen because macOS is reluctant to extend the window past the screen (unless it already does). TODO: is there any way around this?
			set position to {0, 0}
			set size to {1932, 1014}
			set position to {-1310, 973}
		end tell
		set frontmost to true
	end tell
	theProcess
end tell
