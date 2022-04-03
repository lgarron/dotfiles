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
	karabiner \
	mac-git \
	mac-minecraft \
	quicksilver \
	sd-card-backup \
	xdg-basedir-workarounds \
	vscode

.PHONY: mac-common-intel
mac-common-intel: mac-common
	mac-boot-intel

.PHONY: mac-common-arm64
mac-common-arm64: mac-common
	mac-boot-arm64

.PHONY: euclid
euclid: \
	mac-common-intel \
	mac-git-euclid \
	povray

.PHONY: mirzakhani
mirzakhani: \
	mac-common-intel \
	mac-git-github

.PHONY: germain
germain: \
	mac-common-intel \
	mac-git-github

########

PACKAGES  =
PACKAGES += chrome
PACKAGES += fish
PACKAGES += gce-ssh
PACKAGES += golang-fish
PACKAGES += golang-sublime
PACKAGES += hushlogin
PACKAGES += karabiner
PACKAGES += mac-boot-intel
PACKAGES += mac-boot-arm64
PACKAGES += mac-git
PACKAGES += mac-git-euclid
PACKAGES += mac-git-github
PACKAGES += mac-minecraft
PACKAGES += povray
PACKAGES += sd-card-backup
PACKAGES += vscode

PACKAGES += xdg-basedir-workarounds
# PACKAGES += quicksilver # special handling

.PHONY: $(PACKAGES)
$(PACKAGES):
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ $@

########

.PHONY: quicksilver
quicksilver:
	# Link the entire folder for Actions
	cd dotfiles && stow --ignore=.DS_Store -t ~/ $@

########

include setup/chromium.Makefile
include setup/linux.Makefile
include setup/mac.Makefile
