all:
	echo "No default"

########

.PHONY: noether
noether: chrome fish git-chrome gce-ssh osx 

.PHONY: galois
galois: fish git-lgarron osx osx-languages

.PHONY: lgarron1
lgarron1: chrome fish

########

.PHONY: chrome
chrome:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ chrome

.PHONY: fish
fish:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ fish

.PHONY: git-chrome
git-chrome:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ git-chrome

.PHONY: gce-ssh
gce-ssh:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ gce-ssh

.PHONY: git-lgarron
git-lgarron:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ git-lgarron

.PHONY: osx
osx:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ osx

.PHONY: osx-languages
povray:
	cd dotfiles && stow --no-folding --ignore=.DS_Store -t ~/ osx-languages
