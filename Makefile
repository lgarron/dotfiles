all: link

.PHONY: link
link:
	stow --ignore=.DS_Store -t ~/ home

.PHONY: relink
relink:
	stow --restow --ignore=.DS_Store -t ~/ home