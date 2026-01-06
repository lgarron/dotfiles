#!/usr/bin/env -S fish --no-config --

# TODO: make idempotent?
echo "$HOME/.local/share/binaries/linux-x64/fish" >~/.bashrc

make setup

if set -q CODESPACES

    rm -rf \
        "$HOME/.config/fish/config.fish" \
        "$HOME/.local/share/fish"
end

make linux

sudo add-shell "$HOME/.local/share/binaries/linux-x64/fish"
sudo chsh (id -un) --shell "$HOME/.local/share/binaries/linux-x64/fish"

"$HOME/.local/share/binaries/linux-x64/fish" --command 'history append "jj git init --colocate ."'
