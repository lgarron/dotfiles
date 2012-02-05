#!/bin/bash  

cd "`dirname $0`"
DIR=`pwd`

# zsh
ln -s "${DIR}/home/zshrc" "${HOME}/.zshrc"

# git
ln -s "${DIR}/home/gitconfig" "${HOME}/.gitconfig"
ln -s "${DIR}/home/gitignore" "${HOME}/.gitignore"

# cron
ln -s "${DIR}/home/lgcrontab" "${HOME}/.lgcrontab"

# .Xmodmap settings, for OSX-like keybindings in X11 (e.g. Cmd-C copies like Ctrl-C would.)
ln -s "${DIR}/home/Xmodmap" "${HOME}/.Xmodmap"

# tarsnap (backup)
ln -s "${DIR}/home/tarsnaprc" "${HOME}/.tarsnaprc"
