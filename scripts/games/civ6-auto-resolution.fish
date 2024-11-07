#!/usr/bin/env -S fish --no-config

set APP_OPTIONS_PATH (readlink -f "$HOME/Library/Application Support/Sid Meier's Civilization VI/AppOptions.txt")

if /Applications/RDM.app/Contents/MacOS/RDM -l | grep 2560 > /dev/null
  sed -i "" "s/^RenderWidth.*/RenderWidth 5120/" $APP_OPTIONS_PATH
  sed -i "" "s/^RenderHeight.*/RenderHeight 2880/" $APP_OPTIONS_PATH
else
  sed -i "" "s/^RenderWidth.*/RenderWidth 3456/" $APP_OPTIONS_PATH
  sed -i "" "s/^RenderHeight.*/RenderHeight 2160/" $APP_OPTIONS_PATH
end

sed -i "" "s/^FullScreen.*/FullScreen 1/" $APP_OPTIONS_PATH
sed -i "" "s/^UIUpscale.*/UIUpscale 1.000000/" $APP_OPTIONS_PATH
