try
	do shell script "killall CharacterPalette"
	return
end try
tell application "System Events"
	keystroke space using {control down, shift down, command down}
end tell