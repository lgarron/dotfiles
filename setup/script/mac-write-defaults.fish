#!/usr/bin/env fish

# Menu clock
# This might not work arnymore?
defaults write com.apple.menuextra.clock "DateFormat" "EEE MMM d — H:mm:ss"

# Password delay for screensaver
defaults write com.apple.screensaver askForPasswordDelay -int 5
# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -boolean true
# Disable recent apps in the dock
defaults write com.apple.dock show-recents -bool false

# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
# Expand print panel by default
defaults write -g PMPrintingExpandedStateForPrint -bool true


# Instantly dismiss the emoji palette (https://github.com/lgarron/first-world/issues/39)
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

######## System Settings (Organized by Ventura layout order) ########

# General → Date & Time
defaults write NSGlobalDomain AppleICUForce24HourTime -bool True

# Accessibility → Display
defaults write com.apple.universalaccess showWindowTitlebarIcons -bool True
defaults write NSGlobalDomain AppleMenuBarFontSize -string large
# Accessibility → Siri
defaults write com.apple.Siri TypeToSiriEnabled -bool True

# Control Center → Menu Bar Only → Clock → Clock Options…
defaults write com.apple.menuextra.clock ShowSeconds -bool True

# Siri
defaults write com.apple.assistant.support 'Assistant Enabled' -bool True
defaults write com.apple.voicetrigger 'VoiceTrigger Enabled' -bool False
# Set Siri to ⌥⎵
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 '<dict><key>enabled</key><true /><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>2148007936</integer></array><key>type</key><string>modifier</string></dict></dict>'

# (Formerly at: Keyboard → Shortcuts → Full Keyboard Access → All controls)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Keyboard → Keyboard → Delay Until Repeat → shortest setting
# No longer works: defaults write NSGlobalDomain InitialKeyRepeat -int 10
defaults write NSGlobalDomain InitialKeyRepeat -float 15.0
# Keyboard → Text Input → Input Sources → Edit…
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

######## Apps ########

# Finder
defaults write com.apple.finder AppleShowAllFiles YES
defaults write NSGlobalDomain AppleShowAllExtensions YES
defaults write com.apple.finder _FXShowPosixPathInTitle YES
defaults write com.apple.finder ShowStatusBar -bool true
# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# When performing a search: Search the Current Folder
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# New Finder windows show (`PfHm` is the home folder)
defaults write com.apple.finder NewWindowTarget -string PfHm
# Show ~/Library in Finder
chflags nohidden ~/Library
# Keep draggable icons in Finder window title bars
defaults write -g NSWindowSupportsAutomaticInlineTitle -bool false

# Calendar
# Start on Monday
defaults write com.apple.iCal "first day of week" 2

# Misc. Applications
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.FinalCut FFAutoStartBGRender -bool false

# Force settings to take effect
killall SystemUIServer
killall Dock
killall Finder
