#!/usr/bin/env -S fish --no-config

# Wrapper to log commands for easy & safe copy/pasting.
function defaults
  echo -- defaults (string escape -- $argv)
  command defaults $argv
end

# Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write "com.apple.Safari.SandboxBroker" "ShowDevelopMenu" '1'
# Final Cut Pro
  defaults write com.apple.FinalCut FFAutoStartBGRender -bool false
  defaults write "com.apple.FinalCut" "FFImportCopyToMediaFolder" '0'
# Calendar
  # Start on Monday
  defaults write com.apple.iCal "first day of week" 2

# Pixelmator Pro settings
  ## Editing
    # Open Images in → Original Format
    defaults write "com.pixelmatorteam.pixelmator.x" "PXMKitDocumentLossyImageFormatsOpeningBehaviour" 'openInOriginalFormat'
    defaults write "com.pixelmatorteam.pixelmator.x" "PXMKitDocumentProSidecarSupportIsEnabled" '0'
# Caffeinated
  defaults write "design.yugen.Caffeinated" "allowScreenSaver" '1'
# BetterDisplay
  defaults write "pro.betterdisplay.BetterDisplay" "SUAutomaticallyUpdate" '1'
