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
	niceplz \
	quicksilver \
	sd-card-backup \
	xdg-basedir-workarounds \
	vscode \
	zellij

.PHONY: germain
germain: mac-common

.PHONY: pythagoras
germain: \
	mac-common \
	hushlogin # for SSH

.PHONY: linux
linux: \
	fish \
	xdg-basedir-workarounds \
	zellij


########

PACKAGES  =
PACKAGES += git
PACKAGES += hushlogin
PACKAGES += lglogin
PACKAGES += minecraft
PACKAGES += povray
PACKAGES += sd-card-backup
PACKAGES += vscode
PACKAGES += xdg-basedir-workarounds
PACKAGES += niceplz
PACKAGES += zellij

.PHONY: $(PACKAGES)
$(PACKAGES):
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ $@

PACKAGES_FOLDING  =
PACKAGES_FOLDING += compressor
PACKAGES_FOLDING += karabiner
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

########

.PHONY: setup
setup:
	@echo "Run one of the following instead:"
	@echo ""
	@echo "    make setup-dev-dependencies"
	@echo ""
	@echo "    make cargo-setup"
	@echo "    make mac-setup"
	@echo "    make linux-setup"
	@echo ""

.PHONY: setup-dev-dependencies
setup-dev-dependencies:
	@echo "Note: \`make setup\` sets up the repo for development (installing dependencies), it does not set up dotfiles themselves."
	bun install
