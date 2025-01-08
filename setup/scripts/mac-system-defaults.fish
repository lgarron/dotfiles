#!/usr/bin/env -S fish --no-config

# Wrapper to log commands for easy & safe copy/pasting.
function defaults
  echo -- defaults (string escape -- $argv)
  command defaults $argv
end

## Notes
#
# - `NSGlobalDomain` seems to be a synonym for `"Apple Global Domain" (and `-g` is as well?)
# - Some settings are associated specifically with `-currentHost`?
# - Some settings require a reboot.

# System Settings
  ## iCloud (click on signed-in user)
    ### iCloud → See All → iCloud Drive
      # Desktop & Documents Folders → disable
      defaults write "com.apple.finder" "FXICloudDriveDesktop" -boolean false
      defaults write "com.apple.finder" "FXICloudDriveDocuments" -boolean false
      defaults write "com.apple.finder" "SidebarShowingiCloudDesktop" -boolean false
      # Optimize Mac Storage → off
      defaults write "com.apple.bird" "optimize-storage" -boolean false
  ## General
    ### Language & Region
      defaults write NSGlobalDomain "AppleTemperatureUnit" 'Celsius'
      defaults write NSGlobalDomain "AppleFirstWeekday" '{gregorian=2;}'
      defaults write NSGlobalDomain "AppleICUDateFormatStrings" '{1="y-MM-dd";}'
    ### Date & Time
      defaults write NSGlobalDomain AppleICUForce24HourTime -boolean true
      # Closest city → San Francisco
      defaults write "com.apple.chronod" "lastKnownTimes" '{timeZoneSecondsFromGMT="-28800";world="1733305454.026089";}'
  ## Accessibility
    ### Display
      defaults write "com.apple.universalaccess" "showWindowTitlebarIcons" -boolean true
      defaults write NSGlobalDomain AppleMenuBarFontSize -string 'large'
    ### Siri
      defaults write "com.apple.Siri" TypeToSiriEnabled -boolean true
  ## Apple Intelligence & Siri
    defaults write "com.apple.assistant.support" "Assistant Enabled" -boolean true
    # Note: changing the voice trigger settings changes two defaults
    defaults write "com.apple.Siri" "VoiceTriggerUserEnabled" -boolean false
    defaults write "com.apple.voicetrigger" "VoiceTrigger Enabled" -boolean false
    # Keyboard shortcut → Hold Option Space
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 '<dict><key>enabled</key><true /><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>2148007936</integer></array><key>type</key><string>modifier</string></dict></dict>'
    #### Siri Reponses …
      # Voice feedback → off
      defaults write "com.apple.assistant.backedup" "Use device speaker for TTS" -int 3
  ## Control Center
    ### Battery
      defaults write "com.apple.controlcenter" "NSStatusItem Visible Battery" -boolean true
      defaults -currentHost write com.apple.controlcenter.plist BatteryShowPercentage -boolean true
    ### Menu Bar Only
      #### Clock → Clock Options…
        # Show date → always (multiple integer option)
        defaults write "com.apple.menuextra.clock" "ShowDate" -int 1
        defaults write "com.apple.menuextra.clock" "ShowDayOfWeek" -boolean true
        defaults write "com.apple.menuextra.clock" "ShowSeconds" -boolean true
        # defaults write "com.apple.menuextra.clock" "DateFormat" "EEE MMM — H:mm:ss" # TODO: is this officially unsupported now?
      #### Spotlight
        defaults delete "com.apple.Spotlight" "NSStatusItem Visible Item-0" # don't show in menu bar
  ## Control Center
    # Show battery in menu
    defaults write "com.apple.controlcenter" "NSStatusItem Visible Battery" -boolean true
    # Hide Spotlight in menu
    defaults delete "com.apple.Spotlight" "NSStatusItem Visible Item-0"
    # Hide Siri in menu
    defaults delete "com.apple.systemuiserver" "NSStatusItem Visible Siri"
    defaults write "com.apple.Siri" "StatusMenuVisible" -boolean false
  ## Desktop & Dock
    defaults write com.apple.dock "show-recents" -boolean false
    ### Desktop & Stage Manager
      defaults write "com.apple.WindowManager" "GloballyEnabled" -boolean False
      defaults write "com.apple.WindowManager" "EnableTilingByEdgeDrag" -boolean false
      defaults write "com.apple.WindowManager" "EnableTopTilingByEdgeDrag" -boolean false
      defaults write "com.apple.WindowManager" "EnableTilingOptionAccelerator" -boolean false
      defaults write "com.apple.WindowManager" "EnableTiledWindowMargins" -boolean false
    ### Hot Corners…
      defaults write "com.apple.dock" "wvous-tl-corner" -int 1
      defaults write "com.apple.dock" "wvous-tr-corner" -int 1
      defaults write "com.apple.dock" "wvous-bl-corner" -int 1
      defaults write "com.apple.dock" "wvous-br-corner" -int 1
  ## Displays
    ### Advanced
      # Show resolutions as list → on
      defaults write "com.apple.Displays-Settings.extension" '{showListByDefault=1;}'
  ## Privacy & Security
    ### Apple Intelligence Report
      defaults write "com.apple.AppleIntelligenceReport" "lastChanged" -date '2025-01-01 12:00:00 +0000'
      defaults write "com.apple.AppleIntelligenceReport" "reportDuration" -float 0
  ## Keyboard
    defaults write NSGlobalDomain InitialKeyRepeat -float 15.0
    defaults write NSGlobalDomain "KeyRepeat" -float 5
    ### Text Input → Input Sources
      #### Edit…
        defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -boolean false
        defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -boolean false
        defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -boolean false
        defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -boolean false
  ## Mouse
    # TODO: requires a reboot, or at least re-log?
    defaults write NSGlobalDomain "com.apple.mouse.scaling" -float 2.5
  ## Trackpad
    ### Point & Click
      defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" -boolean true
      defaults write "com.apple.AppleMultitouchTrackpad" "Clicking" -boolean true
    ### More Gestures
      defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadTwoFingerFromRightEdgeSwipeGesture" -int 0
      defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadTwoFingerFromRightEdgeSwipeGesture" -int 0
      defaults write "com.apple.dock" "showLaunchpadGestureEnabled" -boolean false
      defaults write "com.apple.dock" "showAppExposeGestureEnabled" -boolean false

# Finder
  defaults write com.apple.finder "AppleShowAllFiles" -boolean true
  defaults write NSGlobalDomain AppleShowAllExtensions -boolean true
  defaults write com.apple.finder _FXShowPosixPathInTitle -boolean true
  defaults write com.apple.finder ShowStatusBar -boolean true
  # Avoid `.DS_Store`, improve perf, respect display defaults more often.
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -boolean true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -boolean true
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -boolean false
  # When performing a search: Search the Current Folder
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  # New Finder windows show (`PfHm` is the home folder)
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  # Keep draggable icons in Finder window title bars
  defaults write NSGlobalDomain NSWindowSupportsAutomaticInlineTitle -boolean false
  # Show ~/Library in Finder
  chflags nohidden ~/Library

# Dock
  # Dim hidden apps in the dock (not in System Settings)
  defaults write com.apple.dock showhidden -boolean true

# Screen capture
  defaults write com.apple.screencapture type heic
  defaults write "com.apple.screencapture" "show-thumbnail" -boolean false

# Modals and palettes
  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -boolean true
  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -boolean true
  # Instantly dismiss the emoji palette (https://github.com/lgarron/first-world/issues/39)
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -boolean false

# Keyboard
  # Formerly at: Keyboard → Shortcuts → Full Keyboard Access → All controls
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Force settings to take effect
killall SystemUIServer
killall Dock
killall Finder
