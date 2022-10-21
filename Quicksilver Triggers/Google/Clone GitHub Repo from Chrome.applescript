tell application "Quicksilver"
	tell application "Google Chrome"
		set theURL to URL of active tab of front window
		do shell script "PATH=${PATH}:/usr/local/bin:/opt/homebrew/bin:${HOME}/local/brew/bin ; gclone '" & theURL & "' &"
	end tell
end tell