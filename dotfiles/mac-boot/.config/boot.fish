#/usr/bin/env fish

# Caps Lock (0x39) -> Delete Key (0x2A)

    # https://developer.apple.com/library/content/technotes/tn2450/_index.html
    hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000002A}]}'

# Set XDG folders

    launchctl setenv XDG_CACHE_HOME "$HOME/.cache"
    launchctl setenv XDG_CONFIG_HOME "$HOME/.config"
    launchctl setenv XDG_DATA_HOME "$HOME/.data"

    # `GPG Keychain.app` requires this.
    launchctl setenv GNUPGHOME "$XDG_CONFIG_HOME/gnupg"

    mkdir -p "$XDG_DATA_HOME/bash"

# Allows us to check when the script was last run.

    launchctl setenv LAST_BOOT_FISH (date)
