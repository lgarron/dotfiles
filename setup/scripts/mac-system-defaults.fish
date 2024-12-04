#!/usr/bin/env -S fish --no-config

function logged
  echo -- $argv
  command $argv
end

# System Settings
  ## iCloud (click on signed-in user)
    ### iCloud
      # Optimize Mac Storage → off
      logged defaults write "com.apple.bird" "optimize-storage" '0'
  ## General
    ### Language & Region
      logged defaults write "Apple Global Domain" "AppleTemperatureUnit" 'Celsius'
      logged defaults write "Apple Global Domain" "AppleFirstWeekday" '{gregorian=2;}
      logged defaults write "Apple Global Domain" "AppleICUDateFormatStrings" '{1="y-MM-dd";}'
    ### Date & Time
      logged defaults write NSGlobalDomain AppleICUForce24HourTime -bool True
      # Closest city → San Francisco
      logged defaults write "com.apple.chronod" "lastKnownTimes" '{timeZoneSecondsFromGMT="-28800";world="1733305454.026089";}'
  ## Accessibility
    ### Display
      logged defaults write "com.apple.universalaccess" "showWindowTitlebarIcons" '0'
      logged defaults write NSGlobalDomain AppleMenuBarFontSize -string large
    ### Siri
      logged defaults write com.apple.Siri TypeToSiriEnabled -bool True
  ## Control Center
    ### Battery
    ### Menu Bar Only
      #### Clock → Clock Options…
        logged defaults write "com.apple.menuextra.clock" "ShowSeconds" '1'
      #### Spotlight
        defaults delete "com.apple.Spotlight" "NSStatusItem Visible Item-0" # don't show in menu bar
  ## Siri & Spotlight
    logged defaults write "com.apple.assistant.support" "Assistant Enabled" '1'
    # Note: changing the voice trigger settings changes two defaults
    logged defaults write "com.apple.Siri" "VoiceTriggerUserEnabled" '0'
    # Note: changing the voice trigger settings changes two defaults
    logged defaults write "com.apple.voicetrigger" "VoiceTrigger Enabled" '0'
    # Keyboard shortcut → Hold Option Space
    logged defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 '<dict><key>enabled</key><true /><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>2148007936</integer></array><key>type</key><string>modifier</string></dict></dict>'
    #### Siri Reponses …
      # Voice feedback → off
      logged defaults write "com.apple.assistant.backedup" "Use device speaker for TTS" '3'
  ## Control Center
    # Show battery in menu
    defaults write "com.apple.controlcenter" "NSStatusItem Visible Battery" '1'
    # Hide Spotlight in menu
    defaults delete "com.apple.Spotlight" "NSStatusItem Visible Item-0"
    # Hide Siri in menu
    defaults write "com.apple.Siri" "StatusMenuVisible" '0'
  ## Desktop & Dock
    logged defaults write com.apple.dock show-recents -bool false
    ### Hot Corners…
      logged defaults write "com.apple.dock" "wvous-tl-corner" '1'
      logged defaults write "com.apple.dock" "wvous-tr-corner" '1'
      logged defaults write "com.apple.dock" "wvous-bl-corner" '1'
      logged defaults write "com.apple.dock" "wvous-br-corner" '1'
  ## Displays
    ### Advanced
      # Show resolutions as list → on
      logged defaults write "com.apple.Displays-Settings.extension" '{showListByDefault=1;}'
  ## Privacy & Security
    ### Apple Intelligence Report
      defaults write "com.apple.AppleIntelligenceReport" '{lastChanged="2024-12-04 13:00:03 +0000";reportDuration=0;}'
  ## Keyboard
      ### Text Input → Input Sources
        #### Edit…
          logged defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
          logged defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
          logged defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
          logged defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false


# Finder
  logged defaults write com.apple.finder AppleShowAllFiles YES
  logged defaults write NSGlobalDomain AppleShowAllExtensions YES
  logged defaults write com.apple.finder _FXShowPosixPathInTitle YES
  logged defaults write com.apple.finder ShowStatusBar -bool true
  # Disable the warning when changing a file extension
  logged defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # When performing a search: Search the Current Folder
  logged defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  # New Finder windows show (`PfHm` is the home folder)
  logged defaults write com.apple.finder NewWindowTarget -string PfHm
  # Keep draggable icons in Finder window title bars
  logged defaults write -g NSWindowSupportsAutomaticInlineTitle -bool false
  # Show ~/Library in Finder
  chflags nohidden ~/Library

# Screen capture
  defaults write "com.apple.screencapture" "show-thumbnail" '0'

### Unsorted/legacy

  # Menu clock
  # This might not work anymore?
  logged defaults write com.apple.menuextra.clock "DateFormat" "EEE MMM d — H:mm:ss"

  # Doesn't work?
  logged defaults write "com.apple.WindowManager" "EnableTilingByEdgeDrag" '0'
  logged defaults write "com.apple.WindowManager" "EnableTopTilingByEdgeDrag" '0'
  logged defaults write "com.apple.WindowManager" "EnableTilingOptionAccelerator" '0'
  logged defaults write "com.apple.WindowManager" "EnableTiledWindowMargins" '0'

  # Password delay for screensaver
  logged defaults write com.apple.screensaver askForPasswordDelay -int 5
  # Disable Dashboard
  # logged defaults write com.apple.dashboard mcx-disabled -boolean true
  # Disable recent apps in the dock
  # Dim hidden apps in the dock
  logged defaults write com.apple.dock showhidden -bool true

  # Expand save panel by default
  logged defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
  # Expand print panel by default
  logged defaults write -g PMPrintingExpandedStateForPrint -bool true

  # Greatly reduce screenshot sizes
  logged defaults write com.apple.screencapture type heic

  # Instantly dismiss the emoji palette (https://github.com/lgarron/first-world/issues/39)
  logged defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

  # (Formerly at: Keyboard → Shortcuts → Full Keyboard Access → All controls)
  logged defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  # Keyboard → Keyboard → Delay Until Repeat → shortest setting
  # No longer works: logged defaults write NSGlobalDomain InitialKeyRepeat -int 10
  logged defaults write NSGlobalDomain InitialKeyRepeat -float 15.0

  ######## Apps ########

# Force settings to take effect
killall SystemUIServer
killall Dock
killall Finder
