all: link

link:
	stow --ignore=.DS_Store -t ~/ home

relink:
	stow --restow --ignore=.DS_Store -t ~/ home