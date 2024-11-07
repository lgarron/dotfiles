#!/bin/bash

set -euo pipefail

if [ "$#" -lt "1" ]
then
  SCRIPT_NAME=$(basename "${0}")
  echo "Usage: ${SCRIPT_NAME} in-file.anything [out-file.flac]"
  exit 1
fi

IN_FILE="${1}"
OUT_FILE="${2:${IN_FILE}.flac}"

if [ -z "${OUT_FILE}" ]
then
  OUT_FILE="${IN_FILE}.flac"
fi

ffmpeg -i "${IN_FILE}" -f flac -qscale:a 0 "${OUT_FILE}"
