#!/usr/bin/env -S fish --no-config

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
    launchctl setenv GNUPGHOME $XDG_CONFIG_HOME/gnupg

    mkdir -p $XDG_DATA_HOME/bash

    # VSCode
    # launchctl setenv VSCODE_EXTENSIONS "$XDG_DATA_HOME"/vscode/extensions

    # zsh
    set ZDOTDIR "$XDG_CONFIG_HOME"/zsh
    mkdir -p $ZDOTDIR
    launchctl setenv ZDOTDIR $ZDOTDIR

    # Docker
    launchctl setenv DOCKER_CONFIG "$XDG_CONFIG_HOME"/docker

    # Python
    launchctl setenv PYTHONSTARTUP $XDG_CONFIG_HOME/python/pythonrc
    mkdir -p $XDG_DATA_HOME/python

# The Naughty List

    rm -rf $HOME/.biome
    rm -rf $HOME/.bundle # Ruby Gems
    rm -rf $HOME/.cargo
    rm -rf $HOME/.cups
    rm -rf $HOME/.docker
    rm -rf $HOME/.dts
    rm -rf $HOME/.gnupg
    rm -rf $HOME/.gradle # Gradle (Java)
    rm -rf $HOME/.npm
    rm -rf $HOME/.oracle_jre_usage
    rm -rf $HOME/.pnpm-state
    rm -rf $HOME/.python_history
    rm -rf $HOME/.rustup
    rm -rf "$HOME/.sentry "
    rm -rf $HOME/.swiftpm
    rm -rf $HOME/.step
    rm -rf $HOME/.terraform.d
    rm -rf $HOME/.thumbnails
    rm -rf $HOME/.yarnrc
    rm -rf $HOME/.vscode-cli
    rm -rf $HOME/.vscode-server
    rm -rf $HOME/.vscode-remote-containers
    rm -rf $HOME/.wasmer
    rm -rf $HOME/go

    # chruby
    rm -rf $HOME/.rubies
    rm -rf $HOME/src

    # Flutter
    rm -rf $HOME/.dart
    rm -rf $HOME/.dart-tool
    rm -rf $HOME/.flutter
    rm -rf $HOME/.flutter-devtools
    rm -rf $HOME/.pub-cache

# Avoid Time Machine slowdown

    # Commented out to avoid a Touch ID prompt.
    # sudo sysctl debug.lowpri_throttle_enabled=0

# Allows us to check when the script was last run.

    launchctl setenv LAST_LGLOGIN_FISH (date)
    date > ~/.config/lglogin.fish.lastrun.txt
