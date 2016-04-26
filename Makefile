all:
	echo "No default"

########

.PHONY: noether
noether: chrome fish gce-ssh gitconfig-noether gitignore-osx golang osx iTerm

.PHONY: galois
galois: fish gitconfig-galois gitignore-osx osx osx-languages golang-dropbox iTerm

.PHONY: lgarron1
lgarron1: chrome fish gitconfig-lgarron1 golang

########

.PHONY: chrome
chrome:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ chrome

.PHONY: fish
fish:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ fish

.PHONY: gce-ssh
gce-ssh:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ gce-ssh

.PHONY: gitconfig-galois
gitconfig-galois:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ gitconfig-galois

.PHONY: gitconfig-noether
gitconfig-noether:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ gitconfig-noether

.PHONY: gitconfig-lgarron1
gitconfig-lgarron1:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ gitconfig-lgarron1

.PHONY: gitignore-osx
gitignore-osx:
	ln -fs $(CURDIR)/dotfiles/gitignore-osx/.gitignore ~

.PHONY: golang
golang:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ golang

.PHONY: golang-dropbox
golang-dropbox:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ golang-dropbox

.PHONY: iTerm
iTerm:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ iTerm
	@echo "Remember to configure iTerm to sync to the right folder."

.PHONY: osx
osx:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ osx

.PHONY: osx-languages
povray:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ osx-languages
