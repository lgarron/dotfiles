.PHONY: mac-setup
mac-setup: mac-defaults mac-backspace mac-apps mac-commandline

.PHONY: mac-defaults
mac-defaults:
	# Finder
	defaults write com.apple.finder AppleShowAllFiles YES
	defaults write NSGlobalDomain AppleShowAllExtensions YES
	defaults write com.apple.finder _FXShowPosixPathInTitle YES
	killall Finder

	# Disable Dashboard
	defaults write com.apple.dashboard mcx-disabled -boolean YES && killall Dock

	# From https://github.com/mathiasbynens/dotfiles
	# Keyboard > Shortcuts > Full Keyboard Access > All controls
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	 
	# Keyboard > Keyboard > Delay Until Repeat > shortest setting
	defaults write NSGlobalDomain InitialKeyRepeat -int 10

	# Applications
	defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

	# Dock
	defaults write com.apple.dock persistent-apps -array "{}"
	killall Dock

.PHONY: mac-backspace
mac-backspace:
	# https://developer.apple.com/library/content/technotes/tn2450/_index.html
	# Caps Lock (0x39) -> Delete Key (0x2A)
	hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000002A}]}'

#TODO: Split apps by machine?
.PHONY: mac-apps
mac-apps: misc-browsers
	brew cask install \
		\ # OS Tools
		bartender \
		bettertouchtool \
		caffeine \
		grandperspective \
		hammerspoon \
		quicksilver \
		switchresx \
		\ # Development (General)
		hex-fiend \
		java \
		rowanj-gitx \
		sublime-text \
		transmit \
		\ # Development (Google)
		androidtool \
		google-cloud-sdk \
		docker \
		\ # Media and Recording
		keycastr \
		obs \
		vlc \
		\ # Misc
		1password \
		julia

CHROME_VERSIONS_TEMP_FOLDER = /tmp/chrome-versions

.PHONY: mac-browsers
mac-browsers:
	brew cask install \
		brave \
		firefox \
		firefoxnightly \
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

.PHONY: mac-commandline
mac-commandline:
	# ffmpeg is excluded for now, because it's super slow to install.
	brew install \
		ag \
		cmake \
		fpp \
		git \
		go \
		hub \
		imagemagick \
		python \
		ssh-copy-id \
		wget
	sudo gem install jekyll
	pip install httpie

.PHONY: mac-right-dock
mac-right-dock:
	defaults write com.apple.dock orientation right && killall Dock