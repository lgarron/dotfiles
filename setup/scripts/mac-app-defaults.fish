#!/usr/bin/env -S fish --no-config

function logged
  echo -- $argv
  command $argv
end

# Safari
  logged defaults write com.apple.Safari IncludeDevelopMenu -bool true
  logged defaults write "com.apple.Safari.SandboxBroker" "ShowDevelopMenu" '1'
# Final Cut Pro
  logged defaults write com.apple.FinalCut FFAutoStartBGRender -bool false
  logged defaults write "com.apple.FinalCut" "FFImportCopyToMediaFolder" '0'
# Calendar
  # Start on Monday
  logged defaults write com.apple.iCal "first day of week" 2

# Pixelmator Pro settings
  ## Editing
    # Open Images in → Original Format
    logged defaults write "com.pixelmatorteam.pixelmator.x" "PXMKitDocumentLossyImageFormatsOpeningBehaviour" 'openInOriginalFormat'
    logged defaults write "com.pixelmatorteam.pixelmator.x" "PXMKitDocumentProSidecarSupportIsEnabled" '0'
# Caffeinated
  logged defaults write "design.yugen.Caffeinated" "allowScreenSaver" '1'
# BetterDisplay
  logged defaults write "pro.betterdisplay.BetterDisplay" "SUAutomaticallyUpdate" '1'
