all:
	echo "No default"

########

.PHONY: noether
noether: chrome fish gce-ssh gitconfig-google gitignore-osx golang osx

.PHONY: galois
galois: fish gitconfig-personal gitignore-osx osx osx-languages golang-dropbox

.PHONY: lgarron1
lgarron1: chrome fish gitconfig-google golang

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

.PHONY: gitconfig-personal
gitconfig-personal:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ gitconfig-personal

.PHONY: gitconfig-google
gitconfig-google:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ gitconfig-google

.PHONY: gitignore-osx
gitignore-osx:
	ln -fs $(CURDIR)/dotfiles/gitignore-osx/.gitignore ~

.PHONY: golang
golang:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ golang

.PHONY: golang-dropbox
golang-dropbox:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ golang-dropbox

.PHONY: osx
osx:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ osx

.PHONY: osx-languages
povray:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ osx-languages
