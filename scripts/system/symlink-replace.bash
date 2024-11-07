#!/bin/bash

set -e

TARGET="${1}"

if [ -L "${TARGET}" ]
then

  SOURCE=$(readlink "${TARGET}")
  echo "Source: ${SOURCE}"

  echo -n "Unlinking... "
  unlink "${TARGET}"
  echo "done."

  echo -n "Moving... "
  mv "${SOURCE}" "${TARGET}"
  echo "done."
fi
