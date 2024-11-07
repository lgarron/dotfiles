#!/usr/bin/env -S fish --no-config

tailscale status --json --active 2>/dev/null | jq -r '.Peer[] | select(.ExitNode == true) | .HostName' | grep -v '^$'
