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
	mac-boot \
	mac-git \
	mac-minecraft \
	mac-sublime-text \
	quicksilver \
	sd-card-backup \
	xdg-basedir-workarounds \
	vscode

.PHONY: euclid
euclid: \
	mac-common \
	mac-git-euclid \
	povray

.PHONY: mirzakhani
mirzakhani: \
	mac-common \
	fish-github \
	mac-git-github

########

PACKAGES  =
PACKAGES += chrome
# PACKAGES += fish # special handling
PACKAGES += gce-ssh
PACKAGES += golang-fish
PACKAGES += fish-github
PACKAGES += golang-sublime
PACKAGES += hushlogin
PACKAGES += karabiner
PACKAGES += mac-boot
PACKAGES += mac-git
PACKAGES += mac-git-euclid
PACKAGES += mac-git-github
PACKAGES += mac-minecraft
PACKAGES += mac-sublime-text
PACKAGES += povray
PACKAGES += sd-card-backup
PACKAGES += vscode

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

include setup/chromium.Makefile
include setup/linux.Makefile
include setup/mac.Makefile
