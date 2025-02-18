.PHONY: auto
auto:
	make "$$(hostname -s | tr '[:upper:]' '[:lower:]')"

########

.PHONY: mac-common
mac-common: \
	mac-setup-sudo \
	mac-common-dotfiles \
	mac-setup \
	mac-setup-bulk \
	setup-dev-dependencies

.PHONY: mac-common-dotfiles
mac-common-dotfiles: \
	mac-text-encoding \
	set-dotfiles-repo-email \
	compressor \
	fish \
	git \
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
pythagoras: \
	mac-common \
	mac-dock-setup-pythagoras-extras \
	mac-apps-server \
	hushlogin # for SSH \

.PHONY: linux
linux: \
	set-dotfiles-repo-email \
	fish \
	xdg-basedir-workarounds \
	zellij

# Sourcing symlinked `.fish` files doesn't seem to work on Dreamhst, so we have to copy all the files we want `fish` to use. 😕
.PHONY: dreamhost
dreamhost:
	mkdir -p ~/.config/fish
	cp -R ./dotfiles/fish/.config/fish/* ~/.config/fish/
	cp -R ./dotfiles/xdg-basedir-workarounds/.config/fish/* ~/.config/fish/

	echo "${HOME}/.shared-hosting/bin/fish" > ~/.bash_profile
	echo "exit" >> ~/.bash_profile
	
	./setup/dreamhost/install-git-commands.bash

########

PACKAGES  =
PACKAGES += git
PACKAGES += hushlogin
PACKAGES += lglogin
PACKAGES += mac-text-encoding
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
	ln -sf ${HOME}/.data/fish ${HOME}/.local/share/fish

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
	bun install --frozen-lockfile

.PHONY: set-dotfiles-repo-email
set-dotfiles-repo-email:
	git config user.email "code@garron.net"

########

.PHONY: test
test: test-help test-completions

.PHONY: test-help
test-help:
	cargo run --bin openscad-auto -- --help
	./scripts/git/tagpush.ts --help
	# ./scripts/git/rmbranch.fish --help # TODO
	# ./scripts/git/rmtag.fish --help # TODO
	scripts/git/node_crunchule.fish --help

.PHONY: test-completions
test-completions:
	cargo run --bin openscad-auto -- --completions fish
	./scripts/git/tagpush.ts --completions fish
	./scripts/git/rmbranch.fish --completions fish
	./scripts/git/rmtag.fish --completions fish

.PHONY: lint
lint:
	npx @biomejs/biome check scripts

.PHONY: format
format:
	npx @biomejs/biome check --write scripts
