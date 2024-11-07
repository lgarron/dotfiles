#!/bin/bash

# Usage: yt [url]

#Constants
MUSIC_FOLDER="${HOME}/Desktop/Music"
URL_ARCHIVE_FOLDER="${MUSIC_FOLDER}/Archive/links"
cd "${MUSIC_FOLDER}/Archive/temp"

# Get the URL
# Frontmost Chrome tab by default.
URL="${1}"
if [[ "${URL}" == "" ]]; then
	URL="$(chrometab)"
fi

# Print out the URL, just in case.
echo "URL: ${URL}"
echo "--------"

# Target file name.
TITLE=$(youtube-dl -o "%(title)s" --get-filename "${URL}")
TITLE="${TITLE//[^a-zA-Z0-9-=\(\)\. ]/}"
FILE=$(youtube-dl -o "%(title)s.%(ext)s" --get-filename "${URL}")
FILE="${FILE//[^a-zA-Z0-9-=\(\)\. ]/}"

# Make a new folder for the download.
cd "${MUSIC_FOLDER}"
#NEW_FOLDER="`unixtime` - ${FILE}"
NEW_FOLDER="${TITLE}"
mkdir "${NEW_FOLDER}"
cd "${NEW_FOLDER}"
open .

# For opening again later.
# echo "[InternetShortcut]\nURL=${URL}" > "${TITLE}.url"
WEBLOC_WITH_ESCAPED_URL=$(echo "${TITLE}.webloc" | sed "s/\&/\&amp;/g")
weblocify "${URL}" "${WEBLOC_WITH_ESCAPED_URL}"
weblocify "${URL}" "${URL_ARCHIVE_FOLDER}/${WEBLOC_WITH_ESCAPED_URL}" # TODO: Use URL or time to avoid exact title collisions.

# youtube-dl
youtube-dl \
	--extract-audio \
	--audio-format flac \
	-o "${FILE}" \
	--write-description \
	--write-info-json "${URL}"
