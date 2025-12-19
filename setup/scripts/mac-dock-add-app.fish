#!/usr/bin/env -S fish --no-config --

set APP_PATH $argv[1]

printf "Adding app to dock: %s" $APP_PATH

defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$APP_PATH</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
