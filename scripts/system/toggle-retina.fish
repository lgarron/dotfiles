#!/usr/bin/env -S fish --no-config

# Uses https://github.com/avibrazil/RDM
# Thanks to https://apple.stackexchange.com/a/368166

if [ "scale = 2.0" = (/Applications/RDM.app/Contents/MacOS/RDM -l | grep -o "scale = \d\.\d") ]
  set NEW_RES "1.0"
else
  set NEW_RES "2.0"
end
/Applications/RDM.app/Contents/MacOS/RDM -s $NEW_RES
