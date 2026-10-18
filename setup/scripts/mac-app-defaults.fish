#!/usr/bin/env -S fish --no-config --

# Wrapper to log commands for easy & safe copy/pasting.
function defaults
    echo -- defaults (string escape -- $argv)
    command defaults $argv
end

# Finder
defaults write "com.apple.finder" "NSToolbar Configuration Browser" '{"TB Default Item Identifiers"=("com.apple.finder.BACK","com.apple.finder.SWCH",NSToolbarSpaceItem,"com.apple.finder.ARNG",NSToolbarSpaceItem,"com.apple.finder.SHAR","com.apple.finder.LABL","com.apple.finder.ACTN",NSToolbarSpaceItem,"com.apple.finder.SRCH",);"TB Display Mode"=2;"TB Icon Size Mode"=1;"TB Is Shown"=1;"TB Item Identifiers"=("com.apple.finder.BACK",NSToolbarSpaceItem,"com.apple.finder.SHAR","com.apple.finder.SRCH",);"TB Size Mode"=1;}'
#Terminal
/usr/libexec/PlistBuddy -c "Set :'Default Window Settings' 'Clear Dark'" $HOME/Library/Preferences/com.apple.Terminal.plist
/usr/libexec/PlistBuddy -c "Set :'Window Settings':'Clear Dark':CommandString 'login -pfq lgarron /opt/homebrew/bin/fish'" $HOME/Library/Preferences/com.apple.Terminal.plist
plutil -replace "Window Settings.Clear Dark.RunCommandAsShell" 'true' -o - $HOME/Library/Preferences/com.apple.Terminal.plist
## View using: 
##
##    plutil -extract "Window Settings.Clear Dark.noWarnProcesses" json -o - $HOME/Library/Preferences/com.apple.Terminal.plist
##
plutil -replace "Window Settings.Clear Dark.noWarnProcesses" -json '[
    {"ProcessName":"screen"},
    {"ProcessName":"tmux"},
    {"ProcessName":"less"},
    {"ProcessName":"more"},
    {"ProcessName":"view"},
    {"ProcessName":"mandoc"},
    {"ProcessName":"tail"},
    {"ProcessName":"log"},
    {"ProcessName":"top"},
    {"ProcessName":"htop"},
    {"ProcessName":"login"},
    {"ProcessName":"-fish"},
    {"ProcessName":"gg"}
]' $HOME/Library/Preferences/com.apple.Terminal.plist
# Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write "com.apple.Safari" IncludeDevelopMenu -bool true
defaults write "com.apple.Safari.SandboxBroker" ShowDevelopMenu -bool true
# Final Cut Pro
defaults write com.apple.FinalCut FFAutoStartBGRender -bool false
defaults write "com.apple.FinalCut" FFImportCopyToMediaFolder -int 0
# Settings → General → Color Correction (sets default UI for color correction)
defaults write "com.apple.FinalCut" FFDefaultColorCorrectionID '"FxPlug:52A68C6D-B49C-41AA-B3EA-03945D0C8EB4_wrapper"'
# TODO: Here, we would:
# - set the default color space for libaries to "Wide Gamut HDR" and
# - set the default color space for new projects (at least when created from an HDR clip) to Rec. 2020 HLG.
# But that doesn't seem possible at the moment.
# Calendar
# Start on Monday
defaults write "com.apple.iCal" "first day of week" -int 2

# iTerm
defaults write "com.googlecode.iterm2" "AllowClipboardAccess" -bool true
defaults write "com.googlecode.iterm2" "WrapDroppedFilenamesInQuotesWhenPasting" -bool true
# Pixelmator Pro settings
## Editing
# Open Images in → Original Format
defaults write "com.pixelmatorteam.pixelmator.x" PXMKitDocumentLossyImageFormatsOpeningBehaviour openInOriginalFormat
defaults write "com.pixelmatorteam.pixelmator.x" PXMKitDocumentProSidecarSupportIsEnabled -boolean false
# Caffeinated
defaults write "design.yugen.Caffeinated" allowScreenSaver -bool true
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
defaults write "org.openscad.OpenSCAD" "advanced.renderBackend3D" -string Manifold
defaults write "org.openscad.OpenSCAD" "advanced.consoleFontFamily" -string '"Ubuntu Mono"'
defaults write "org.openscad.OpenSCAD" "advanced.customizerFontFamily" -string '"Ubuntu Mono"'
defaults write "org.openscad.OpenSCAD" "advanced.toolbarExport3D" -string binstl
defaults write "org.openscad.OpenSCAD" "advanced.toolbarExport2D" -string svg
