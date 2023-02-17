.PHONY: auto
auto:
	make "$$(hostname -s | tr '[:upper:]' '[:lower:]')"

########

.PHONY: mac-common
mac-common: \
	fish \
	golang-fish \
	karabiner \
	mac-git \
	mac-minecraft \
	mac-minecraft-mods \
	quicksilver \
	sd-card-backup \
	xdg-basedir-workarounds \
	vscode

.PHONY: mac-common-intel
mac-common-intel: mac-common
	make mac-lglogin-intel

.PHONY: mac-common-arm64
mac-common-arm64: mac-common
	make mac-lglogin-arm64

.PHONY: euclid
euclid: \
	mac-common-intel \
	mac-git-euclid \
	povray

.PHONY: germain
germain: \
	mac-common-arm64 \
	mac-git-github

########

PACKAGES  =
PACKAGES += chrome
PACKAGES += gce-ssh
PACKAGES += golang-fish
PACKAGES += golang-sublime
PACKAGES += hushlogin
PACKAGES += mac-lglogin-intel
PACKAGES += mac-lglogin-arm64
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

PACKAGES_FOLDING  =
PACKAGES_FOLDING += karabiner
PACKAGES_FOLDING += mac-minecraft-mods
PACKAGES_FOLDING += quicksilver

.PHONY: $(PACKAGES_FOLDING)
$(PACKAGES_FOLDING):
	# Link the entire folder to work around https://github.com/pqrs-org/Karabiner-Elements/issues/3248
	cd dotfiles && stow --ignore=.DS_Store -t ~/ $@

########

.PHONY: fish
fish:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ fish
	mkdir -p ${HOME}/.data/fish
	mkdir -p ${HOME}/.local/share
	ln -sf ${HOME}/.data/fish ${HOME}/.local/share/

########

include setup/chromium.Makefile
include setup/linux.Makefile
include setup/mac.Makefile
