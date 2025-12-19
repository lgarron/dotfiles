#!/usr/bin/env -S fish --no-config --

set DIR $argv[1]
echo "Setting screenshot dir to: $DIR"
defaults write com.apple.screencapture location $DIR

echo "Restarting "(set_color --bold)"SystemUIServer"
killall SystemUIServer
