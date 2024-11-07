#!/bin/bash

set -euo pipefail

osascript -e 'tell application "Safari" to get URL of current tab of front window'
