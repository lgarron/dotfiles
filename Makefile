all:
	echo "No default"

########

.PHONY: mac-common
mac-common: \
	ag\
	chrome-osx\
	chrome\
	fish\
	gce-ssh\
	gitconfig-noether\
	gitignore-osx\
	golang\
	iTerm\
	osx\
	quicksilver

.PHONY: noether
noether: mac-common

.PHONY: hypatia
hypatia: mac-common

.PHONY: agnesi
agnesi: mac-common

.PHONY: galois
galois: ag fish gitconfig-galois gitignore-osx osx osx-languages golang-dropbox iTerm karabiner

.PHONY: lgarron1
lgarron1: ag chrome fish gitconfig-lgarron1 golang

########

PACKAGES  =
PACKAGES += ag
PACKAGES += chrome
PACKAGES += chrome-osx
PACKAGES += fish
PACKAGES += gce-ssh
PACKAGES += gitconfig-galois
PACKAGES += gitconfig-noether
PACKAGES += gitconfig-lgarron1
PACKAGES += gitignore-osx
PACKAGES += golang
PACKAGES += golang-dropbox
# PACKAGES += iTerm # special handling
PACKAGES += osx
PACKAGES += osx-languages

.PHONY: $(PACKAGES)
$(PACKAGES):
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ $@

########

.PHONE: quicksilver
quicksilver:
	# Link the entire folder for Actions
	cd dotfiles && stow --ignore=.DS_Store -t ~/ $@


## TODO
# defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

########

MAKEFILE_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ITERM_DIR := ${MAKEFILE_DIR}/iTerm
ITERM_DEFAULTS_COMMAND = defaults write ~/Library/Preferences/com.googlecode.iterm2.plist

.PHONY: iTerm
iTerm:
	@echo "Setting up iTerm to sync preferences with ${ITERM_DIR}"
	${ITERM_DEFAULTS_COMMAND} NoSyncNeverRemindPrefsChangesLostForFile_selection -int 0
	${ITERM_DEFAULTS_COMMAND} LoadPrefsFromCustomFolder -bool YES
	${ITERM_DEFAULTS_COMMAND} PrefsCustomFolder -string ${ITERM_DIR}

include macOS.Makefile
include chromium.Makefile
