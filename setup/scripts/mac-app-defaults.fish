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
  defaults write "com.apple.FinalCut" "FFImportCopyToMediaFolder" -int 0
  # Settings → General → Color Correction (sets default UI for color correction)
  defaults write "com.apple.FinalCut" "FFDefaultColorCorrectionID" '"FxPlug:52A68C6D-B49C-41AA-B3EA-03945D0C8EB4_wrapper"'
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
# OpenSCAD
  defaults write "org.openscad.OpenSCAD" "design.autoReload" '1'
  defaults write "org.openscad.OpenSCAD" "advanced.renderBackend3D" 'Manifold'
  defaults write "org.openscad.OpenSCAD" "3dview.colorscheme" '"Tomorrow Night"'
  defaults write "org.openscad.OpenSCAD" "advanced.toolbarExport2D" 'svg'
  defaults write "org.openscad.OpenSCAD" "feature.lazy-union" '1'
  defaults write "org.openscad.OpenSCAD" "view.hideEditor" '1'
