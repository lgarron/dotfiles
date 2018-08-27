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

	# Menu clock
	defaults write com.apple.menuextra.clock "DateFormat" "EEE MMM d  H:mm:ss"
	killall SystemUIServer
	# Calendar: start on Monday
	defaults write com.apple.iCal "first day of week" 1

	# Password delay for screensaver
	defaults write com.apple.screensaver askForPasswordDelay -int 5
	# Disable Dashboard
	defaults write com.apple.dashboard mcx-disabled -boolean YES && killall Dock

	# Keyboard > Shortcuts > Full Keyboard Access > All controls
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	# Keyboard > Keyboard > Delay Until Repeat > shortest setting
	defaults write NSGlobalDomain InitialKeyRepeat -int 10
	# Keyboard > Text > Add period with double-space
	defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

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
	qlmanage -r

CHROME_VERSIONS_TEMP_FOLDER = /tmp/chrome-versions

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

.PHONY: mac-chrome-versions
mac-chrome-versions:
	mkdir -p "${CHROME_VERSIONS_TEMP_FOLDER}/stable"
	brew cask install google-chrome --appdir="${CHROME_VERSIONS_TEMP_FOLDER}/stable"
	mv "${CHROME_VERSIONS_TEMP_FOLDER}/stable/Google Chrome.app" "/Applications/Google Chrome Stable.app"

	mkdir -p "${CHROME_VERSIONS_TEMP_FOLDER}/beta"
	brew cask install Caskroom/versions/google-chrome-beta --appdir="${CHROME_VERSIONS_TEMP_FOLDER}/beta"
	mv "${CHROME_VERSIONS_TEMP_FOLDER}/beta/Google Chrome.app" "/Applications/Google Chrome Beta.app"

	mkdir -p "${CHROME_VERSIONS_TEMP_FOLDER}/dev"
	brew cask install Caskroom/versions/google-chrome-dev --appdir="${CHROME_VERSIONS_TEMP_FOLDER}/dev"
	mv "${CHROME_VERSIONS_TEMP_FOLDER}/dev/Google Chrome.app" "/Applications/Google Chrome Dev.app"

	mkdir -p "${CHROME_VERSIONS_TEMP_FOLDER}/canary"
	brew cask install Caskroom/versions/google-chrome-canary --appdir="${CHROME_VERSIONS_TEMP_FOLDER}/canary"
	mv "${CHROME_VERSIONS_TEMP_FOLDER}/canary/Google Chrome Canary.app" "/Applications/Google Chrome Canary.app"

	killall "Google Chrome"
	rm -rf "/Applications/Google Chrome.app"
