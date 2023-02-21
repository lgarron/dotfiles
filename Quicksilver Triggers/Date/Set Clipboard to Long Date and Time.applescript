--set the clipboard to (do shell script "date \"+%Y-%m-%d at %H:%M:%S\"")
set the clipboard to (do shell script "date \"+%Y-%m-%d@%H-%M-%S\"")

--delay 0.1

--tell application "System Events"
--	keystroke "v" using {command down}
--end tell