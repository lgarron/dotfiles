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

    function rm_and_log
        set NAUGHTY_PATH $argv[1]
        if test -e $NAUGHTY_PATH
            rm -rf $NAUGHTY_PATH
            /opt/homebrew/bin/bun run \
                /Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/storage/counter-file.ts \
                /Users/lgarron/.config/lglogin/naughty-list.(date "+%Y-%m").json \
                $NAUGHTY_PATH
        end
    end

    rm_and_log $HOME/.angular-config.json
    rm_and_log $HOME/.biome
    rm_and_log $HOME/.bundle # Ruby Gems
    rm_and_log $HOME/.cargo
    rm_and_log $HOME/.cups
    rm_and_log $HOME/.docker
    rm_and_log $HOME/.dts
    rm_and_log $HOME/.gnupg
    rm_and_log $HOME/.gradle # Gradle (Java)
    rm_and_log $HOME/.hugindata
    rm_and_log $HOME/.lldb
    rm_and_log $HOME/.npm
    rm_and_log $HOME/.oracle_jre_usage
    rm_and_log $HOME/.pnpm-state
    rm_and_log $HOME/.profile # Created by `rustup`
    rm_and_log $HOME/.python_history
    rm_and_log $HOME/.rnd
    rm_and_log $HOME/.rustup
    rm_and_log "$HOME/.sentry "
    rm_and_log $HOME/.swiftpm
    rm_and_log $HOME/.step
    rm_and_log $HOME/.terraform.d
    rm_and_log $HOME/.thumbnails # Blender (among others)
    rm_and_log $HOME/.yarn
    rm_and_log $HOME/.yarnrc
    rm_and_log $HOME/.vscode-cli
    rm_and_log $HOME/.vscode-server
    rm_and_log $HOME/.vscode-remote-containers
    rm_and_log $HOME/.wasmer
    rm_and_log $HOME/bin # Something Python-related?
    rm_and_log $HOME/go

    # Flutter
    rm_and_log $HOME/.dart
    rm_and_log $HOME/.dart-tool
    rm_and_log $HOME/.flutter
    rm_and_log $HOME/.flutter-devtools
    rm_and_log $HOME/.pub-cache

    # See: https://github.com/lgarron/first-world/issues/239
    # This is currently commented because I'm testing out using a locked folder instead.
    # rm_and_log "$HOME/Library/Application Support/Google/Chrome/OptGuideOnDeviceModel/"

# niceplz

    /opt/homebrew/bin/niceplz-sudo

# Allows us to check when the script was last run.

    launchctl setenv LAST_LGLOGIN_FISH (date)
    echo "End: "(date) >> ~/.config/lglogin/lastrun.log
