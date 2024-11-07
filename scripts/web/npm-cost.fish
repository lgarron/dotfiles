#!/usr/bin/env -S fish --no-config

set TEMP_DIR (mktemp -d)
cd $TEMP_DIR
echo "{}" > package.json
set_color --dim
npm install --no-progress --no-color -- $argv | string replace -ra '[^[:print:]]' ''

set_color --dim
echo "--------"
set_color normal
echo -n "Number of files: "
find node_modules -type f | wc -l | tr -d " "
set_color normal

set_color --dim
echo "--------"
set_color normal
echo -n "Number of bytes: "
du -sh node_modules

rm -rf $TEMP_DIR
