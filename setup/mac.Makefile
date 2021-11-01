# Bootstrap

BREWFILE_FOLDER = ./setup/Brewfiles

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
	defaults write com.apple.dashboard mcx-disabled -boolean
	# Disable recent apps in the dock
	defaults write com.apple.dock show-recents -bool false
	killall Dock

	# Keyboard > Shortcuts > Full Keyboard Access > All controls
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	# Keyboard > Keyboard > Delay Until Repeat > shortest setting
	defaults write NSGlobalDomain InitialKeyRepeat -int 10
	# Keyboard > Text > Add period with double-space
	defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
	# Keyboard > Text > Use smart quotes and dashes
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

	# Expand save panel by default
	defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
	# Expand print panel by default
	defaults write -g PMPrintingExpandedStateForPrint -bool true

	# Applications
	defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
	defaults write com.apple.Safari IncludeDevelopMenu -bool true

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
