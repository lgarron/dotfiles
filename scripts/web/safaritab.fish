#!/usr/bin/env -S fish --no-config

osascript -e 'tell application "Safari" to get URL of current tab of front window'
