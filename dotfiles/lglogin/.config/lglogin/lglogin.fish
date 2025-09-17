#!/usr/bin/env -S fish --no-config

    echo "Start: "(date) > ~/.config/lglogin/lastrun.log

# Caps Lock (0x39) -> Delete Key (0x2A)

    # https://developer.apple.com/library/content/technotes/tn2450/_index.html
    hidutil property --set '{"UserKeyMapping":[
        {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x070000002A},
        {"HIDKeyboardModifierMappingSrc":0x700000049,"HIDKeyboardModifierMappingDst":0xFF00000003},
    ]}'

# Set XDG folders

    launchctl setenv XDG_CACHE_HOME "$HOME/.cache"
    launchctl setenv XDG_CONFIG_HOME "$HOME/.config"
    launchctl setenv XDG_DATA_HOME "$HOME/.data"
    launchctl setenv XDG_STATE_HOME "$HOME/.state"

    # `GPG Keychain.app` requires this.
    launchctl setenv GNUPGHOME $XDG_CONFIG_HOME/gnupg

    mkdir -p $XDG_DATA_HOME/bash

    # VSCode
    # launchctl setenv VSCODE_EXTENSIONS "$XDG_DATA_HOME"/vscode/extensions

    # `zsh`
    set ZDOTDIR "$XDG_CONFIG_HOME"/zsh
    mkdir -p $ZDOTDIR
    launchctl setenv ZDOTDIR $ZDOTDIR

    # Docker
    launchctl setenv DOCKER_CONFIG "$XDG_CONFIG_HOME"/docker

    # Python
    launchctl setenv PYTHONSTARTUP $XDG_CONFIG_HOME/python/pythonrc
    mkdir -p $XDG_DATA_HOME/python

# The Naughty List

    /opt/homebrew/bin/naughty-list-auto

# niceplz

    /opt/homebrew/bin/niceplz-sudo

# Allows us to check when the script was last run.

    launchctl setenv LAST_LGLOGIN_FISH (date)
    echo "End: "(date) >> ~/.config/lglogin/lastrun.log
