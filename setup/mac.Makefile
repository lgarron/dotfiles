.PHONY: mac-setup
mac-setup: mac-fish-default-shell mac-defaults mac-apps-core mac-commandline-core

.PHONY: mac-setup-extra
mac-setup: mac-apps-extra mac-commandline-extra mac-quicklook

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

.PHONY: reset-dock
reset-dock:
	defaults write com.apple.dock persistent-apps -array "{}"
	killall Dock

.PHONY: mac-apps-core
mac-apps-core:
	brew cask install \
		bettertouchtool \
		quicksilver \
		iterm2 \
		sublime-text \
		1password

#TODO: Split apps by machine?
.PHONY: mac-apps-extra
mac-apps-extra: mac-browsers
	brew cask install \
		bartender \
		caffeine \
		grandperspective \
		switchresx \
		hex-fiend \
		java \
		rowanj-gitx \
		transmit \
		androidtool \
		docker \
		keycastr \
		obs \
		vlc \
		julia

.PHONY: mac-commandline-core
mac-commandline-core:
	# ffmpeg is excluded for now, because it's super slow to install.
	brew install \
		ag \
		fish \
		git \
		python

.PHONY: mac-commandline-extra
mac-commandline-extra:
	# ffmpeg is excluded for now, because it's super slow to install.
	brew install \
		cmake \
		fpp \
		go \
		hub \
		imagemagick \
		ssh-copy-id \
		wget
	sudo gem install jekyll
	pip install httpie

.PHONY: mac-quicklook
mac-quicklook:
	brew cask install \
		betterzipql \
		qlmarkdown \
		qlstephen \
		suspicious-package
	qlmanage -r

CHROME_VERSIONS_TEMP_FOLDER = /tmp/chrome-versions

.PHONY: mac-browsers
mac-browsers:
	brew cask install \
		brave \
		firefox \
		firefoxnightly \
		google-chrome \
		opera \
		vivaldi

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

.PHONY: mac-right-dock
mac-right-dock:
	defaults write com.apple.dock orientation right && killall Dock

FISH_PATH = ${HOME}/local/brew/bin/fish
.PHONY: mac-fish-default-shell
mac-fish-default-shell:
	brew install fish
	fish -c "source ~/.config/fish/config.fish"
	cat /etc/shells | grep "${FISH_PATH}" > /dev/null || echo "${FISH_PATH}" | sudo tee -a /etc/shells
	chsh -s "${FISH_PATH}"
