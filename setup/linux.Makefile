.PHONY: linux-setup
linux-setup: linux-fish-default-shell

.PHONY: linux-fish-default-shell
linux-fish-default-shell:
	sudo apt-get install fish
	fish -c "source ~/.config/fish/config.fish"
	chsh -s "`which fish`"
