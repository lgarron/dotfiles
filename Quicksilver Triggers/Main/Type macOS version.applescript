on shell(command)
	do shell script "/opt/homebrew/bin/trampoline " & command
end shell

set theProductName to shell("sw_vers -productName")
set theProductVersion to shell("sw_vers -productVersion")

set theVersion to theProductName & " " & theProductVersion

tell application "System Events" to keystroke theVersion
