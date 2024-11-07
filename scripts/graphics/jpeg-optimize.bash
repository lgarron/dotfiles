#!/bin/bash


FILE="${1}"
FILE_TMP="${FILE}.recompress-temp.jpg"
echo "----------------"
echo "Recompressing ${FILE}."
nice -n 20 jpeg-recompress "${FILE}" "${FILE_TMP}" && \
  du -h "${FILE}" && \
  du -h "${FILE_TMP}" && \
  rm "${FILE}" && \
  mv "${FILE_TMP}" "${FILE}"