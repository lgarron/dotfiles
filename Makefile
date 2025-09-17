LSTOW = bun run ./scripts/system/lstow/lstow.ts

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
	naughty-list \
	niceplz \
	quicksilver \
	sd-card-backup \
	xdg-basedir-workarounds \
	vscode \
	vscode-settings-macos \
	zellij \
	ripgrep

.PHONY: germain
germain: mac-common

.PHONY: pythagoras
pythagoras: \
	mac-common \
	mac-dock-setup-pythagoras-extras \
	mac-apps-server \
	pythagoras-screenshots-macos \
	hushlogin # for SSH

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
PACKAGES += compressor
PACKAGES += git
PACKAGES += hushlogin
PACKAGES += jj
PACKAGES += karabiner
PACKAGES += mac-text-encoding
PACKAGES += minecraft
PACKAGES += naughty-list
PACKAGES += niceplz
PACKAGES += povray
PACKAGES += quicksilver
PACKAGES += ripgrep
PACKAGES += sd-card-backup
PACKAGES += vscode
PACKAGES += xdg-basedir-workarounds
PACKAGES += zellij

.PHONY: $(PACKAGES)
$(PACKAGES):
	${LSTOW} -- ./dotfiles/$@ ~/

########

.PHONY: fish
fish:
	${LSTOW} -- ./dotfiles/$@ ~/
	mkdir -p ${HOME}/.data/fish
	mkdir -p ${HOME}/.local/share
	rm -rf ${HOME}/.local/share/fish
	ln -sf ${HOME}/.data/fish ${HOME}/.local/share/

# Daemons

.PHONY: lglogin
lglogin:
	${LSTOW} -- ./dotfiles/$@ ~/
	launchctl print gui/501/net.garron.mac.lglogin > /dev/null 2> /dev/null || \
		launchctl bootstrap gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.lglogin.plist

.PHONY: lglogin-uninstall-daemon
lglogin-uninstall-daemon:
	launchctl print gui/501/net.garron.mac.lglogin > /dev/null 2> /dev/null && \
		launchctl bootout gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.lglogin.plist \
		|| echo "Already uninstalled"
	rm -f /Users/lgarron/Library/LaunchAgents/net.garron.mac.lglogin.plist

.PHONY: vscode-settings-macos
vscode-settings-macos:
	${LSTOW} -- ./dotfiles/$@ ~/
	launchctl print gui/501/net.garron.mac.dotfiles.mirror.vscode-settings-macos > /dev/null 2> /dev/null || \
		launchctl bootstrap gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.vscode-settings-macos.plist

.PHONY: vscode-settings-macos-uninstall-daemon
vscode-settings-macos-uninstall-daemon:
	launchctl print gui/501/net.garron.mac.dotfiles.mirror.vscode-settings-macos > /dev/null 2> /dev/null && \
		launchctl bootout gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.vscode-settings-macos.plist \
		|| echo "Already uninstalled"
	rm -f /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.vscode-settings-macos.plist

.PHONY: obsidian-backup-macos
obsidian-backup-macos:
	${LSTOW} -- ./dotfiles/$@ ~/
	launchctl print gui/501/net.garron.mac.dotfiles.mirror.obsidian-backup-macos > /dev/null 2> /dev/null || \
		launchctl bootstrap gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.obsidian-backup-macos.plist

.PHONY: obsidian-backup-macos-uninstall-daemon
obsidian-backup-macos-uninstall-daemon:
	launchctl print gui/501/net.garron.mac.dotfiles.mirror.obsidian-backup-macos > /dev/null 2> /dev/null && \
		launchctl bootout gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.obsidian-backup-macos.plist \
		|| echo "Already uninstalled"
	rm -f /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.obsidian-backup-macos.plist

.PHONY: pythagoras-screenshots-macos
pythagoras-screenshots-macos:
	${LSTOW} -- ./dotfiles/$@ ~/
	launchctl print gui/501/net.garron.mac.dotfiles.mirror.pythagoras-screenshots-macos > /dev/null 2> /dev/null || \
		launchctl bootstrap gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.pythagoras-screenshots-macos.plist

.PHONY: pythagoras-screenshots-macos-uninstall-daemon
pythagoras-screenshots-macos-uninstall-daemon:
	launchctl print gui/501/net.garron.mac.dotfiles.mirror.pythagoras-screenshots-macos > /dev/null 2> /dev/null && \
		launchctl bootout gui/$(shell id -u) /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.pythagoras-screenshots-macos.plist \
		|| echo "Already uninstalled"
	rm -f /Users/lgarron/Library/LaunchAgents/net.garron.mac.dotfiles.mirror.pythagoras-screenshots-macos.plist

########

include setup/linux.Makefile
include setup/mac.Makefile

########

# We match the convention from https://github.com/lgarron/Makefile-convention
.PHONY: setup
setup: setup-caveat setup-npm-packages

.PHONY: setup-caveat
setup-caveat:
	@echo "Note: \`make setup\` sets up the repo for development (installing dependencies), it does not set up dotfiles themselves."

.PHONY: setup-npm-packages
setup-npm-packages:
	bun install --frozen-lockfile

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
test: test-help test-completions test-bun

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
	./scripts/git/rmtag.ts --completions fish

.PHONY: lint
lint: lint-ts-biome lint-ts-tsc lint-rust

.PHONY: lint-ts-biome
lint-ts-biome: setup-npm-packages
	bun x @biomejs/biome check

.PHONY: lint-ts-tsc
lint-ts-tsc: setup-npm-packages
	bun x tsc --project .

.PHONY: lint-rust
lint-rust:
	cargo clippy -- --deny warnings
	cargo fmt --check

.PHONY: format
format: format-ts-biome format-rust

.PHONY: format-ts-biome
format-ts-biome: setup-npm-packages
	bun x @biomejs/biome check --write

.PHONY: format-rust
format-rust:
	cargo clippy --fix --allow-no-vcs
	cargo fmt

.PHONY: test-bun
test-bun:
	bun test
