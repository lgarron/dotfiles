#!/usr/bin/env fish

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

    # `GPG Keychain.app` requires this.
    launchctl setenv GNUPGHOME "$XDG_CONFIG_HOME/gnupg"

    mkdir -p "$XDG_DATA_HOME/bash"

    # VSCode
    # launchctl setenv VSCODE_EXTENSIONS "$XDG_DATA_HOME"/vscode/extensions

    # zsh
    set -x ZDOTDIR "$XDG_CONFIG_HOME"/zsh
    mkdir -p $ZDOTDIR
    launchctl setenv ZDOTDIR $ZDOTDIR

    # Docker
    launchctl setenv DOCKER_CONFIG "$XDG_CONFIG_HOME"/docker

# Avoid Time Machine slowdown

    # Commented out to avoid a Touch ID prompt.
    # sudo sysctl debug.lowpri_throttle_enabled=0

# Allows us to check when the script was last run.

    launchctl setenv LAST_LGLOGIN_FISH (date)
    date > ~/.config/lglogin.fish.lastrun.txt
