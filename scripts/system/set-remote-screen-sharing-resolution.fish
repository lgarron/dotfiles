#!/usr/bin/env -S fish --no-config

# Set the remote screen sharing resolution for a given computer automatically.
# Hardcoded to a 5K monitor and the 16-inch MacBook Pro.

if [ (count $argv) -gt 0 ]
  set REMOTE $argv[1]
  if /Applications/RDM.app/Contents/MacOS/RDM -l | grep 2560 > /dev/null
    nohup ssh $REMOTE "/Applications/RDM.app/Contents/MacOS/RDM -w 2560 -h 1440 -s 2" &; disown
  else
    nohup ssh $REMOTE "/Applications/RDM.app/Contents/MacOS/RDM -w 1728 -h 1080 -s 2" &; disown
  end
else
  echo "Please specify a remote server."
end


