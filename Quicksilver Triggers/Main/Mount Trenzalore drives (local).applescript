on shell(command)
	do shell script "env PATH=\"$PATH:/opt/homebrew/bin\" " & command
end shell

tell application "Finder"
	mount volume "smb://Pythagoras.tlb/Trenzalore"
	mount volume "smb://Pythagoras.tlb/Trenzalore CRM Videos"
end tell

shell("/opt/homebrew/bin/reveal-macos /Volumes/Trenzalore/")
