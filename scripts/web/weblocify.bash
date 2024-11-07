#!/bin/bash

set -euo pipefail

if [ "$#" -lt "1" ]
then
  SCRIPT_NAME=$(basename "${0}")
  echo "Usage: ${SCRIPT_NAME} URL file.webloc"
  exit 1
fi

URL="${1}"
FILE_NAME="${2}"

echo "Starting ${FILE_NAME}"

# Basic URL encoding
URL=`echo "${URL}" | sed "s/\&/\&amp;/g"`

V=`cat <<HEREDOC
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>URL</key>
  <string>$URL</string>
</dict>
</plist>
HEREDOC`

echo -n "${V}" > "$FILE_NAME"

echo "Done ${FILE_NAME}"
