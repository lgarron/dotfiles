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
	setup

.PHONY: mac-common-dotfiles
mac-common-dotfiles: \
	mac-text-encoding \
	set-dotfiles-repo-email \
	compressor \
	fish \
	git \
	jj \
	karabiner \
	lglogin \
	minecraft \
	niceplz \
	quicksilver \
	sd-card-backup \
	xdg-basedir-workarounds \
	vscode \
	zellij \
	ripgrep

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
	zellij \
	ripgrep

# Sourcing symlinked `.fish` files doesn't seem to work on Dreamhst, so we have to copy all the files we want `fish` to use. 😕
.PHONY: dreamhost
dreamhost:
	mkdir -p ~/.config/fish
	cp -R ./dotfiles/fish/.config/fish/* ~/.config/fish/
	cp -R ./dotfiles/xdg-basedir-workarounds/.config/fish/* ~/.config/fish/

	echo "${HOME}/.shared-hosting/bin/fish" > ~/.bash_profile
	echo "exit" >> ~/.bash_profile

########

PACKAGES  =
PACKAGES += git
PACKAGES += hushlogin
PACKAGES += jj
PACKAGES += mac-text-encoding
PACKAGES += minecraft
PACKAGES += povray
PACKAGES += sd-card-backup
PACKAGES += vscode
PACKAGES += xdg-basedir-workarounds
PACKAGES += niceplz
PACKAGES += zellij
PACKAGES += ripgrep

.PHONY: $(PACKAGES)
$(PACKAGES):
	bun run ./scripts/system/lstow.ts -- ./dotfiles/$@ ~/

PACKAGES_FOLDING  =
PACKAGES_FOLDING += compressor
PACKAGES_FOLDING += karabiner
PACKAGES_FOLDING += quicksilver

.PHONY: $(PACKAGES_FOLDING)
$(PACKAGES_FOLDING):
	# Link the entire folder to work around https://github.com/pqrs-org/Karabiner-Elements/issues/3248
	bun run ./scripts/system/lstow.ts -- ./dotfiles/$@ ~/

########

.PHONY: fish
fish:
	bun run ./scripts/system/lstow.ts -- ./dotfiles/$@ ~/
	mkdir -p ${HOME}/.data/fish
	mkdir -p ${HOME}/.local/share
	rm -rf ${HOME}/.local/share/fish
	ln -sf ${HOME}/.data/fish ${HOME}/.local/share/

.PHONY: lglogin
lglogin:
	bun run ./scripts/system/lstow.ts -- ./dotfiles/$@ ~/
	launchctl print gui/501/net.garron.mac.lglogin > /dev/null 2> /dev/null || \
		launchctl bootstrap gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.lglogin.plist

.PHONY: lglogin-uninstall-daemon
lglogin-uninstall-daemon:
	launchctl print gui/501/net.garron.mac.lglogin > /dev/null 2> /dev/null && \
		launchctl bootout gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.lglogin.plist \
		|| echo "Already uninstalled"

########

include setup/linux.Makefile
include setup/mac.Makefile
include setup/rust.Makefile # TODO: Figure out Rustup vs. Homebrew so this can be added to `mac-common`.

########

# We match the convention from https://github.com/lgarron/Makefile-convention
.PHONY: setup
setup:
	@echo "Note: \`make setup\` sets up the repo for development (installing dependencies), it does not set up dotfiles themselves."
	bun install --frozen-lockfile
	# TODO: also try running this right after VS Code is installed.
	# TODO: whyyyy does `make` use an incompatible `command` so that we can't run `command -qv code`???
	command -v code > /dev/null && git config filter.normalizeVSCodeSettings.clean "./.config/git-filter/normalizeVSCodeSettings.ts" || echo -n ""

.PHONY: set-dotfiles-repo-email
set-dotfiles-repo-email:
	if test -d .git; \
	then \
		git config user.email "code@garron.net"; \
	fi
	if test -d .jj; \
	then \
		jj config set --repo user.name "Lucas Garron"; \
		jj config set --repo user.email code@garron.net; \
	fi
	# TODO: When do we need to run `jj describe --reset-author --no-edit`?

# We match the convention from https://github.com/lgarron/Makefile-convention
.PHONY: clean
clean:
	@echo "Note: \`make clean\` cleans up the repo itself, it does not affect configured files."
	rm -rf ./.temp

# We match the convention from https://github.com/lgarron/Makefile-convention
.PHONY: reset
reset: clean
	@echo "Note: \`make reset\` resets up the repo itself, it does not affect configured files."
	rm -rf ./node_modules ./target

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
lint: lint-ts-biome lint-ts-tsc lint-rust

.PHONY: lint-ts-biome
lint-ts-biome:
	bun x @biomejs/biome check

.PHONY: lint-ts-tsc
lint-ts-tsc:
	bun x tsc --project .

.PHONY: lint-rust
lint-rust:
	cargo clippy -- --deny warnings
	cargo fmt --check

.PHONY: format
format: format-ts-biome format-rust

.PHONY: format-ts-biome
format-ts-biome:
	bun x @biomejs/biome check --write

.PHONY: format-rust
format-rust:
	cargo clippy --fix --allow-no-vcs
	cargo fmt
