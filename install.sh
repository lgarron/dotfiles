#!/bin/bash  

cd "`dirname $0`"
DIR=`pwd`

ln -s "${DIR}/home/bash_profile" "${HOME}/.bash_profile"
ln -s "${DIR}/home/tarsnaprc" "${HOME}/.tarsnaprc"
ln -s "${DIR}/home/gitconfig" "${HOME}/.gitconfig"
ln -s "${DIR}/home/gitignore" "${HOME}/.gitignore"
ln -s "${DIR}/home/lgcrontab" "${HOME}/.lgcrontab"
ln -s "${DIR}/home/zshrc" "${HOME}/.zshrc"