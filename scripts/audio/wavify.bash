#!/bin/bash

set -euo pipefail

if [ "$#" -lt "1" ]
then
  SCRIPT_NAME=$(basename "${0}")
  echo "Usage: ${SCRIPT_NAME} in-file.anything [out-file.wav]"
  exit 1
fi

IN_FILE="${1}"
OUT_FILE="${2:-${IN_FILE}.wav}"

ffmpeg -i "${IN_FILE}" -f wav "${OUT_FILE}"
