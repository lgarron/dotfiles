#!/usr/bin/env -S fish --no-config

if /Applications/RDM.app/Contents/MacOS/RDM -l | grep 2560 > /dev/null
  /Applications/RDM.app/Contents/MacOS/RDM -w 1728 -h 1080 -s 2
else
  /Applications/RDM.app/Contents/MacOS/RDM -w 2560 -h 1440 -s 2
end
