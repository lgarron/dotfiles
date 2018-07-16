.PHONY: auto
auto:
	make "$$(hostname -s | tr '[:upper:]' '[:lower:]')"

######## Config

# Handle $PATH in case we're on a Mac.
HOMEBREW_PATH = $(HOME)/local/brew

PATH  := "$(PATH):${HOMEBREW_PATH}/bin"
SHELL := env PATH=${PATH} /bin/bash

########

.PHONY: mac-common
mac-common: \
	fish \
	golang-fish \
	hushlogin \
	iTerm \
	karabiner \
	mac-boot \
	mac-git \
	mac-sublime-text \
	quicksilver \
	xdg-basedir-workarounds

.PHONY: euclid
euclid: \
	mac-common \
	mac-minecraft \
	povray \
	sd-card-backup

########

PACKAGES  =
PACKAGES += chrome
# PACKAGES += fish # special handling
PACKAGES += gce-ssh
PACKAGES += golang-fish
PACKAGES += golang-sublime
PACKAGES += hushlogin
# PACKAGES += iTerm # special handling
PACKAGES += karabiner
PACKAGES += mac-boot
PACKAGES += mac-git
PACKAGES += mac-minecraft
PACKAGES += mac-sublime-text
PACKAGES += povray
PACKAGES += sd-card-backup

PACKAGES += xdg-basedir-workarounds
# PACKAGES += quicksilver # special handling

.PHONY: $(PACKAGES)
$(PACKAGES):
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ $@

########

. PHONY: fish
fish:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ $@
	fish -c "source ~/.config/fish/config.fish"

.PHONY: quicksilver
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

include setup/chromium.Makefile
include setup/linux.Makefile
include setup/mac.Makefile
