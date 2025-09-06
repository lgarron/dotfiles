#!/usr/bin/env -S fish --no-config

repo dependencies --package-manager npm roll --commit $argv
