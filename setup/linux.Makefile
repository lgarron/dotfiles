.PHONY: linux-setup
linux-setup: linux-fish-default-shell

.PHONY: linux-fish-default-shell
linux-fish-default-shell:
	sudo apt-get install fish
	chsh -s "`which fish`"
