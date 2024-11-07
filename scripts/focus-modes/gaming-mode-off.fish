#!/usr/bin/env -S fish --no-config

/Applications/Arq.app/Contents/Resources/arqc pauseBackups 0 > /dev/null

defaults write com.apple.screencapture location "'/Users/lgarron/Dropbox (Maestral)/Screenshots/Germain Screenshots/Germain Screenshots 2024'"
killall SystemUIServer

osascript -e 'quit app "Audio Hijack"'
