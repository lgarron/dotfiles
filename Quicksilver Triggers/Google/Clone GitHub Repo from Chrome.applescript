tell application "Quicksilver"
	tell application "Google Chrome"
		set theURL to URL of active tab of front window
		set quotedURL to quoted form of theURL
		do shell script "env PATH=\"$PATH:/opt/homebrew/bin\" gclone " & quotedURL & " > /dev/null 2>&1 &"
	end tell
end tell