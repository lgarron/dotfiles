on is_running(appName)
	tell application "System Events" to (name of processes) contains appName
end is_running

repeat while is_running("BambuStudio")
	tell application "BambuStudio"
		quit
	end tell
end repeat
