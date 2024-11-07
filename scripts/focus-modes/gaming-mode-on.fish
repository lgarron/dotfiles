#!/usr/bin/env -S fish --no-config

# We set the pause to 6 hours. This is rather long, but it's immediately reset by the corresponding off script.
/Applications/Arq.app/Contents/Resources/arqc pauseBackups 360 > /dev/null

defaults write com.apple.screencapture location "/Volumes/VIDEOLAND/Screencaps/"
killall SystemUIServer

open -a "Audio Hijack"
