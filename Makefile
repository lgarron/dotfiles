.PHONY: auto
auto:
	make "$$(hostname -s | tr '[:upper:]' '[:lower:]')"

########

.PHONY: mac-common
mac-common: \
	compressor \
	fish \
	git \
	hushlogin \
	karabiner \
	lglogin \
	minecraft \
	minecraft-mods \
	niceplz \
	quicksilver \
	sd-card-backup \
	xdg-basedir-workarounds \
	vscode

.PHONY: germain
germain: mac-common

.PHONY: pythagoras
germain: \
	mac-common \
	hushlogin # for SSH

.PHONY: linux
linux: fish xdg-basedir-workarounds


########

PACKAGES  =
PACKAGES += civilization
PACKAGES += git
PACKAGES += hushlogin
PACKAGES += lglogin
PACKAGES += minecraft
PACKAGES += povray
PACKAGES += sd-card-backup
PACKAGES += vscode
PACKAGES += xdg-basedir-workarounds
PACKAGES += niceplz

.PHONY: $(PACKAGES)
$(PACKAGES):
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ $@

PACKAGES_FOLDING  =
PACKAGES_FOLDING += compressor
PACKAGES_FOLDING += karabiner
PACKAGES_FOLDING += minecraft-mods
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

include setup/linux.Makefile
include setup/mac.Makefile
include setup/rust.Makefile # TODO: Figure out Rustup vs. Homebrew so this can be added to `mac-common`.
