#!/bin/bash

set -e

if [ "$#" -lt "1" ]; then
	SCRIPT_NAME=$(basename "${0}")
	echo "Wraps RX100 AVCHD files into a \`.mov\` that macOS likes."
	echo "(Copies audio codec, flattens audio to full-quality PCM.)"
	echo ""
	echo "Usage: ${SCRIPT_NAME} 00000.MTS [out-file.mov]"
	exit 1
fi

OUT_FILE="${2}"

if [ -z "${OUT_FILE}" ]; then
	OUT_FILE="${1}.mov"
fi

if [ -f "${OUT_FILE}" ]; then
	echo "${OUT_FILE} already exists."
	exit 1
fi

ffmpeg -i "${1}" -vcodec copy -acodec pcm_s16le "${OUT_FILE}" && touch -r "${1}" "${OUT_FILE}"
