#!/bin/bash

set -e

if [ "$#" -lt "1" ]
then
  SCRIPT_NAME=$(basename "${0}")
  echo "Usage: ${SCRIPT_NAME} 1234"
  exit 1
fi

PORT="${1}"

echo "Killing all processes using port ${PORT}"

# The two successive invocations could theoretically be out of sync. But if port
# processes have a race condition like that, then this script was probably not
# going to help much anyhow.
lsof -i "tcp:${PORT}" || (echo "No processes!" ; exit 0)
lsof -ti "tcp:${PORT}" | xargs kill -9
