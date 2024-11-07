#!/usr/bin/env -S fish --no-config

# Full `fish` path is hardcoded so it works outside the shell (e.g. using Karabiner). Note that a symlink at `$HOME/Dropbox` doesn't seem to work for this.
set PARENT_FOLDER "$HOME/Dropbox (Maestral)/Screenshots/Germain Screenshots/Germain App Screenshots/"

set DATE_STRING (date "+%Y-%m-%d — %H-%M-%S")

set WINDOW_ID_ARG ""
if [ "$argv[1]" = "--front-window-shadowed-png" ]
  set WINDOW_ID (osascript -e 'tell application (path to frontmost application as text) to id of window 1')
  set EXTENSION "heic"
  set WINDOW_ID_ARG -l$WINDOW_ID
else if [ "$argv[1]" = "--front-window-shadowless-jpg" ]
  set WINDOW_ID (osascript -e 'tell application (path to frontmost application as text) to id of window 1')
  set EXTENSION "heic"
  set WINDOW_ID_ARG -l$WINDOW_ID
else
  set EXTENSION "heic"
end

set TEMP_FILE $PARENT_FOLDER/$DATE_STRING" — temp "(time random 1 10000000000).$EXTENSION
echo "taking!"
screencapture -l$WINDOW_ID -o -t $EXTENSION $TEMP_FILE
echo "taken!"

# Some examples of `application process` properties:
#
# - VS Code
#   - `short name`: "Code"
#   - `name`: "Electron"
#   - `bundle identifier` "com.microsoft.VSCode"
# - No Man's Sky
#   - `short name`: "No Man's Sky"
#   - `name`: "No Man's Sky"
#   - `bundle identifier`: "uk.co.hellogames.nms"
# - Minecraft
#   - `short name`: missing value
#   - `name`: "java"
#   - `bundle identifier`: vissing value
#
# So we use `short name` if available, else `name`.
set APP_NAME (osascript -e 'tell application "System Events"
	set appName to short name of first application process whose frontmost is true
	if appName is missing value then
		set appName to name of first application process whose frontmost is true
	end if
	appName
end tell')
if string match -e $APP_NAME java
  set APP_NAME "Minecraft"
end
echo $APP_NAME
set APP_FOLDER "$PARENT_FOLDER/$APP_NAME"
mkdir -p $APP_FOLDER

set FILE_NAME "$APP_FOLDER/$DATE_STRING — $APP_NAME.$EXTENSION"
mv $TEMP_FILE $FILE_NAME

# TODO: better arg handling
if [ "$argv[1]" = "--reveal" ]
  open -R $FILE_NAME
end
if [ "$argv[2]" = "--reveal" ]
  open -R $FILE_NAME
end
# /Applications/ImageOptim.app/Contents/MacOS/ImageOptim $FILE_NAME &

# Permission needed for: /Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_console_user_server
