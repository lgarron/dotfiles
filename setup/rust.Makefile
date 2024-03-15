.PHONY: cargo-setup
cargo-setup:
	cargo install cargo-binstall
	cargo binstall \
		cargo-run-bin \
		cargo-bump \
		cargo-watch
