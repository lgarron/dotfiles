.PHONY: auto
auto:
	make "$$(hostname -s)"

########

.PHONY: mac-common
mac-common: \
	ag \
	fish \
	gitattributes-mac \
	gitignore-osx \
	golang-fish \
	hushlogin \
	iTerm \
	osx \
	quicksilver

.PHONY: mac-work
mac-work: \
	chrome-osx \
	chrome \
	gitconfig-noether \
	golang-work

.PHONY: noether
noether: mac-common mac-work

.PHONY: hypatia
hypatia: mac-common mac-work

.PHONY: agnesi
agnesi: mac-common

.PHONY: galois
galois: \
	mac-common \
	gitconfig-euclid \
	osx-languages

.PHONY: euclid
euclid: galois

########

.PHONY: linux-work
linux-work: \
	ag \
	chrome \
	fish \
	gitconfig-lgarron1 \
	golang-fish \
	golang-work \
	hushlogin

.PHONY: lgarron1
lgarron1: linux-work

.PHONY: lovelace
lovelace: linux-work

########

PACKAGES  =
PACKAGES += ag
PACKAGES += chrome
PACKAGES += chrome-osx
PACKAGES += fish
PACKAGES += gce-ssh
PACKAGES += gitattributes-mac
PACKAGES += gitconfig-euclid
PACKAGES += gitconfig-noether
PACKAGES += gitconfig-lgarron1
PACKAGES += gitignore-osx
PACKAGES += golang-dropbox
PACKAGES += golang-fish
PACKAGES += golang-work
PACKAGES += hushlogin
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
