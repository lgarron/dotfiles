#!/bin/bash

for arg in "${@:2}"
do
  "${1}" "$arg"
done
