on shell(command)
	do shell script "env PATH=\"$PATH:/opt/homebrew/bin\" " & command
end shell

tell application "Quicksilver"
	tell application "Google Chrome"
		set theURL to URL of active tab of front window
		set quotedURL to quoted form of theURL
		tell me to shell("jclone " & quotedURL & " > /dev/null 2>&1 &")
	end tell
end tell
