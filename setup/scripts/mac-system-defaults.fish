#!/usr/bin/env -S fish --no-config

# Wrapper to log commands
function defaults
  echo -- defaults (string escape -- $argv)
  command defaults $argv
end

# System Settings
  ## iCloud (click on signed-in user)
    ### iCloud
      # Optimize Mac Storage → off
      defaults write "com.apple.bird" "optimize-storage" '0'
  ## General
    ### Language & Region
      defaults write "Apple Global Domain" "AppleTemperatureUnit" 'Celsius'
      defaults write "Apple Global Domain" "AppleFirstWeekday" '{gregorian=2;}'
      defaults write "Apple Global Domain" "AppleICUDateFormatStrings" '{1="y-MM-dd";}'
    ### Date & Time
      defaults write NSGlobalDomain AppleICUForce24HourTime -bool True
      # Closest city → San Francisco
      defaults write "com.apple.chronod" "lastKnownTimes" '{timeZoneSecondsFromGMT="-28800";world="1733305454.026089";}'
  ## Accessibility
    ### Display
      defaults write "com.apple.universalaccess" "showWindowTitlebarIcons" '0'
      defaults write NSGlobalDomain AppleMenuBarFontSize -string large
    ### Siri
      defaults write com.apple.Siri TypeToSiriEnabled -bool True
  ## Control Center
    ### Battery
    ### Menu Bar Only
      #### Clock → Clock Options…
        defaults write "com.apple.menuextra.clock" "ShowSeconds" '1'
      #### Spotlight
        defaults delete "com.apple.Spotlight" "NSStatusItem Visible Item-0" # don't show in menu bar
  ## Siri & Spotlight
    defaults write "com.apple.assistant.support" "Assistant Enabled" '1'
    # Note: changing the voice trigger settings changes two defaults
    defaults write "com.apple.Siri" "VoiceTriggerUserEnabled" '0'
    # Note: changing the voice trigger settings changes two defaults
    defaults write "com.apple.voicetrigger" "VoiceTrigger Enabled" '0'
    # Keyboard shortcut → Hold Option Space
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 '<dict><key>enabled</key><true /><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>2148007936</integer></array><key>type</key><string>modifier</string></dict></dict>'
    #### Siri Reponses …
      # Voice feedback → off
      defaults write "com.apple.assistant.backedup" "Use device speaker for TTS" '3'
  ## Control Center
    # Show battery in menu
    defaults write "com.apple.controlcenter" "NSStatusItem Visible Battery" '1'
    # Hide Spotlight in menu
    defaults delete "com.apple.Spotlight" "NSStatusItem Visible Item-0"
    # Hide Siri in menu
    defaults write "com.apple.Siri" "StatusMenuVisible" '0'
  ## Desktop & Dock
    defaults write com.apple.dock show-recents -bool false
    ### Hot Corners…
      defaults write "com.apple.dock" "wvous-tl-corner" '1'
      defaults write "com.apple.dock" "wvous-tr-corner" '1'
      defaults write "com.apple.dock" "wvous-bl-corner" '1'
      defaults write "com.apple.dock" "wvous-br-corner" '1'
  ## Displays
    ### Advanced
      # Show resolutions as list → on
      defaults write "com.apple.Displays-Settings.extension" '{showListByDefault=1;}'
  ## Privacy & Security
    ### Apple Intelligence Report
      defaults write "com.apple.AppleIntelligenceReport" '{lastChanged="2024-12-04 13:00:03 +0000";reportDuration=0;}'
  ## Keyboard
    ### Text Input → Input Sources
      #### Edit…
        defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
        defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
        defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
        defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  ## Mouse
    defaults write "Apple Global Domain" "com.apple.mouse.scaling" '"2.5"'
  ## Trackpad
    ### Point & Click
      defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" '1'
      defaults write "com.apple.AppleMultitouchTrackpad" "Clicking" '1'
    ### More Gestures
      defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadTwoFingerFromRightEdgeSwipeGesture" '0'
      defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadTwoFingerFromRightEdgeSwipeGesture" '0'
      defaults write "com.apple.dock" "showLaunchpadGestureEnabled" '0'

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
  # Keep draggable icons in Finder window title bars
  defaults write -g NSWindowSupportsAutomaticInlineTitle -bool false
  # Show ~/Library in Finder
  chflags nohidden ~/Library

# Screen capture
  defaults write "com.apple.screencapture" "show-thumbnail" '0'

### Unsorted/legacy

  # Menu clock
  # This might not work anymore?
  defaults write com.apple.menuextra.clock "DateFormat" "EEE MMM d — H:mm:ss"

  # Doesn't work?
  defaults write "com.apple.WindowManager" "EnableTilingByEdgeDrag" '0'
  defaults write "com.apple.WindowManager" "EnableTopTilingByEdgeDrag" '0'
  defaults write "com.apple.WindowManager" "EnableTilingOptionAccelerator" '0'
  defaults write "com.apple.WindowManager" "EnableTiledWindowMargins" '0'

  # Password delay for screensaver
  defaults write com.apple.screensaver askForPasswordDelay -int 5
  # Disable Dashboard
  # defaults write com.apple.dashboard mcx-disabled -boolean true
  # Disable recent apps in the dock
  # Dim hidden apps in the dock
  defaults write com.apple.dock showhidden -bool true

  # Expand save panel by default
  defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
  # Expand print panel by default
  defaults write -g PMPrintingExpandedStateForPrint -bool true

  # Greatly reduce screenshot sizes
  defaults write com.apple.screencapture type heic

  # Instantly dismiss the emoji palette (https://github.com/lgarron/first-world/issues/39)
  defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

  # (Formerly at: Keyboard → Shortcuts → Full Keyboard Access → All controls)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  # Keyboard → Keyboard → Delay Until Repeat → shortest setting
  # No longer works: defaults write NSGlobalDomain InitialKeyRepeat -int 10
  defaults write NSGlobalDomain InitialKeyRepeat -float 15.0

  ######## Apps ########

# Force settings to take effect
killall SystemUIServer
killall Dock
killall Finder
