#!/usr/bin/env -S fish --no-config

# Wrapper to log commands for easy & safe copy/pasting.
function defaults
  echo -- defaults (string escape -- $argv)
  command defaults $argv
end

# Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write "com.apple.Safari" "IncludeDevelopMenu" -bool true
  defaults write "com.apple.Safari.SandboxBroker" "ShowDevelopMenu" -bool true
# Final Cut Pro
  defaults write com.apple.FinalCut FFAutoStartBGRender -bool false
  defaults write "com.apple.FinalCut" "FFImportCopyToMediaFolder" -int 0
  # Settings → General → Color Correction (sets default UI for color correction)
  defaults write "com.apple.FinalCut" "FFDefaultColorCorrectionID" '"FxPlug:52A68C6D-B49C-41AA-B3EA-03945D0C8EB4_wrapper"'
  # TODO: Here, we would:
  # - set the default color space for libaries to "Wide Gamut HDR" and
  # - set the default color space for new projects (at least when created from an HDR clip) to Rec. 2020 HLG.
  # But that doesn't seem possible at the moment.
# Calendar
  # Start on Monday
  defaults write "com.apple.iCal" "first day of week" -int 2

# Pixelmator Pro settings
  ## Editing
    # Open Images in → Original Format
    defaults write "com.pixelmatorteam.pixelmator.x" "PXMKitDocumentLossyImageFormatsOpeningBehaviour" 'openInOriginalFormat'
    defaults write "com.pixelmatorteam.pixelmator.x" "PXMKitDocumentProSidecarSupportIsEnabled" -boolean false
# Caffeinated
  defaults write "design.yugen.Caffeinated" "allowScreenSaver" -bool true
# OpenSCAD
  ## Menu
    defaults write "org.openscad.OpenSCAD" "design.autoReload" -bool true
    defaults write "org.openscad.OpenSCAD" "view.hideEditor" -bool true
  ## Setings
    ### 3D View
      defaults write "org.openscad.OpenSCAD" "3dview.colorscheme" '"Tomorrow Night"'
    ### Editor
      defaults write "org.openscad.OpenSCAD" "editor.fontfamily" -string '"Ubuntu Mono"'
    ### Features
      defaults write "org.openscad.OpenSCAD" "feature.lazy-union" -bool true
    ### Advanced
      defaults write "org.openscad.OpenSCAD" "advanced.renderBackend3D" -string 'Manifold'
      defaults write "org.openscad.OpenSCAD" "advanced.consoleFontFamily" -string '"Ubuntu Mono"'
      defaults write "org.openscad.OpenSCAD" "advanced.customizerFontFamily" -string '"Ubuntu Mono"'
      defaults write "org.openscad.OpenSCAD" "advanced.toolbarExport3D" -string 'binstl'
      defaults write "org.openscad.OpenSCAD" "advanced.toolbarExport2D" -string 'svg'

# TODO: this requires `sudo` and a reboot?
# https://www.reddit.com/r/MacOS/comments/16wzdk9/is_there_a_way_to_turn_off_the_new_emoji/
# https://mastodon.social/@stroughtonsmith/112216657091717306
# defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist emoji_enhancements -dict-add Enabled -bool NO
