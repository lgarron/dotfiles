# Bootstrap

BREWFILE_FOLDER = ./setup/Brewfiles
MAC_ADD_SHORTCUT = ./setup/script/mac-add-shortcut.fish

# TODO: Use installation path instead of .PHONY?
.PHONY: mac-homebrew
mac-homebrew: ${HOMEBREW_PATH}

${HOMEBREW_PATH}:
	echo "Skipping Homebrew installation"

# Main Installations

.PHONY: mac-setup
mac-setup: \
	mac-homebrew \
	mac-defaults \
	mac-keyboard-shortcuts \
	mac-file-defaults \
	mac-commandline-core \
	mac-apps-core \
	mac-fish-default-shell

.PHONY: mac-setup-extra
mac-setup-extra: \
	mac-apps-extra \
	mac-commandline-extra \
	mac-quicklook

# Definitions

.PHONY: mac-fish-default-shell
mac-fish-default-shell: mac-commandline-core
	cat /etc/shells | grep "`which fish`" > /dev/null || echo "`which fish`" | sudo tee -a /etc/shells
	chsh -s "`which fish`"

.PHONY: mac-defaults
mac-defaults:
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
	killall Finder
	# Show ~/Library in Finder
	chflags nohidden ~/Library
	# Keep draggable icons in Finder window title bars
	defaults write -g NSWindowSupportsAutomaticInlineTitle -bool false

	# Menu clock
	defaults write com.apple.menuextra.clock "DateFormat" "EEE MMM d  H:mm:ss"
	killall SystemUIServer
	# Calendar: start on Monday
	defaults write com.apple.iCal "first day of week" 1

	# Password delay for screensaver
	defaults write com.apple.screensaver askForPasswordDelay -int 5
	# Disable Dashboard
	defaults write com.apple.dashboard mcx-disabled -boolean true
	# Disable recent apps in the dock
	defaults write com.apple.dock show-recents -bool false
	killall Dock

	# Keyboard > Shortcuts > Full Keyboard Access > All controls
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	# Keyboard > Keyboard > Delay Until Repeat > shortest setting
	defaults write NSGlobalDomain InitialKeyRepeat -int 10
	# Keyboard > Text
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

	# Expand save panel by default
	defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
	# Expand print panel by default
	defaults write -g PMPrintingExpandedStateForPrint -bool true

	# Applications
	defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
	defaults write com.apple.Safari IncludeDevelopMenu -bool true

	# Instantly dismiss the emoji palette (https://github.com/lgarron/first-world/issues/39)
	defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

.PHONY: mac-keyboard-shortcuts
mac-keyboard-shortcuts:
	# Global
	${MAC_ADD_SHORTCUT} "NSGlobalDomain"            "Emoji & Symbols"          "^⌥⇧⌘R" # unset default
	# Chrome
	${MAC_ADD_SHORTCUT} "com.google.Chrome"         "Extensions"               "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.google.Chrome.canary"  "Extensions"               "⇧⌘E"
	${MAC_ADD_SHORTCUT} "org.chromium.Chromium"     "Extensions"               "⇧⌘E"
	# Paste and Match Style
	${MAC_ADD_SHORTCUT} "com.tinyspeck.slackmacgap" "Paste and Match Style"    "⇧⌘V"
	${MAC_ADD_SHORTCUT} "com.apple.iWork.Pages"     "Paste and Match Style"    "⇧⌘V"
	${MAC_ADD_SHORTCUT} "com.bloombuilt.dayone-mac" "Paste as Plain Text"      "⇧⌘V"
	# Export
	${MAC_ADD_SHORTCUT} "com.bloombuilt.dayone-mac" "JSON"                     "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.iMovieApp"       "File…"                    "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.iWork.Pages"     "PDF…"                     "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.garageband10"    "Export Song to Disk…"     "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.adobe.mas.lightroomCC" "Export…"                  "⇧⌘E"
	${MAC_ADD_SHORTCUT} "com.adobe.mas.lightroomCC" "Edit in Photoshop…"       "⇧⌘P"
	${MAC_ADD_SHORTCUT} "com.apple.FinalCut"        "'HEVC (H.265) up to 4K…'" "⇧⌘E"
	# Consistency with other programs
	${MAC_ADD_SHORTCUT} "com.apple.contacts"        "Edit Card"                "⌘E"
	${MAC_ADD_SHORTCUT} "com.apple.Safari"          "Reload Page From Origin"  "⇧⌘R"
	${MAC_ADD_SHORTCUT} "org.audacityteam.audacity" "Save Project As…"         "⇧⌘S"

.PHONY: mac-file-defaults
mac-file-defaults:
	which duti || brew install duti

	# File formats

	duti -s com.google.Chrome org.ietf.mhtml all
	duti -s com.google.Chrome public.url all
	duti -s com.google.Chrome public.svg-image all
	duti -s com.google.Chrome http all
	duti -s com.google.Chrome https all

	duti -s com.microsoft.vscode public.data all
	duti -s com.microsoft.vscode public.plain-text all
	duti -s com.microsoft.vscode net.daringfireball.markdown all
	duti -s com.microsoft.vscode public.json all

	duti -s com.apple.quicktimeplayerx com.microsoft.waveform-audio all # wav
	duti -s com.apple.quicktimeplayerx com.apple.m4v-video all
	duti -s com.apple.quicktimeplayerx com.apple.m4a-audio all
	duti -s com.apple.quicktimeplayerx org.xiph.flac all
	duti -s com.apple.quicktimeplayerx public.mp3 all

	# https://github.com/moretension/duti/issues/29
	# duti -s com.google.Chrome public.html all
	@echo -e "\n\nCannot set HTML handler. Right-click an HTML file in Finder to set as default.\n\n"

.PHONY: mac-commandline-core
mac-commandline-core:
	brew bundle --file=${BREWFILE_FOLDER}/commandline-core.txt

.PHONY: mac-commandline-extra
mac-commandline-extra:
	brew bundle --file=${BREWFILE_FOLDER}/commandline-extra.txt
	gem install jekyll
	pip install httpie

.PHONY: mac-apps-core
mac-apps-core:
	brew bundle --file=${BREWFILE_FOLDER}/core.txt

#TODO: Split apps by machine?
.PHONY: mac-apps-extra
mac-apps-extra: mac-browsers
	brew bundle --file=${BREWFILE_FOLDER}/extra.txt

.PHONY: mac-quicklook
mac-quicklook:
	brew bundle --file=${BREWFILE_FOLDER}/quicklook.txt

	# https://gregbrown.co/code/typescript-quicklook
	@echo "Set Quicklook to handle .ts files as text (TypeScript) instead of video."
	touch /tmp/ts-file-extension-test.ts
	# TODO: Make this idempotent.
	plutil \
		-insert "CFBundleDocumentTypes.0.LSItemContentTypes.1" \
		-string $(shell mdls -raw -name kMDItemContentType /tmp/ts-file-extension-test.ts) \
		${HOME}/Library/QuickLook/QLColorCode.qlgenerator/Contents/Info.plist

	qlmanage -r

.PHONY: mac-browsers
mac-browsers:
	brew bundle --file=${BREWFILE_FOLDER}/browsers.txt

# Extra

.PHONY: reset-dock
reset-dock:
	defaults write com.apple.dock persistent-apps -array "{}"
	killall Dock

.PHONY: mac-right-dock
mac-right-dock:
	defaults write com.apple.dock orientation right && killall Dock
