#!/usr/bin/env -S fish --no-config

osascript -e 'tell application "Google Chrome" to get URL of active tab of front window'
