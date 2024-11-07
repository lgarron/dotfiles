#!/bin/bash

set -euo pipefail

if [ "$#" -lt "1" ]
then
  SCRIPT_NAME=$(basename "${0}")
  echo "Usage: ${SCRIPT_NAME} in-file.anything [out-file.mp3]"
  exit 1
fi

IN_FILE="${1}"
OUT_FILE="${2:-${IN_FILE}.mp3}"

command_exists () {
    type "$1" &> /dev/null ;
}

function convert_wav_to_mp3 {
  if command_exists lame
  then
    lame --preset extreme "${IN_FILE}" "${OUT_FILE}"
  else
    # 256k is a decent tradeoff for files that might still be reprocessed in the future.
    ffmpeg -i "${IN_FILE}" -ab 256k "${OUT_FILE}"
  fi
}

FILE_TYPE="${1##*.}"

if [ "${FILE_TYPE}" = "wav" ]
then
  convert_wav_to_mp3 "${IN_FILE}" 
else
  TEMP=$(mktemp "$1.XXXX")
  rm "${TEMP}"
  wavify "${IN_FILE}" "${TEMP}"
  convert_wav_to_mp3 "${TEMP}" "${OUT_FILE}"
  rm "${TEMP}"
fi
