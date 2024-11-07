#!/bin/bash

set -euo pipefail

osascript -e 'tell application "Google Chrome" to get URL of active tab of front window'
