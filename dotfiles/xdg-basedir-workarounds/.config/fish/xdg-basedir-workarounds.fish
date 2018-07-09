# This file contains hacks to make programs respect the XDG basedir
# specification. The main purpose of this is to get them to stop pollluting
# $HOME with dotfiles.

## Env vars

    # Explicitly set env vars to the default paths, since that will occasionally
    # get programs to behave.
    set XDG_CACHE_HOME "$HOME/.cache"
    set XDG_CONFIG_HOME "$HOME/.config"
    set XDG_DATA_HOME "$HOME/.data"

## XDG workarounds for specific programs.

    # TODO: Remove if https://github.com/facebook/PathPicker/issues/269 is fixed.
    set -x FPP_DIR "$XDG_DATA_HOME/fpp/"

    set -x LESSHISTFILE "$XDG_DATA_HOME/lesshst"

    # GnPG
    # See `boot.fish` for `launchctl setenv`
    set -x GNUPGHOME "$XDG_CONFIG_HOME/gnupg"

    # HTTPie
    # Workaround from https://github.com/jakubroztocil/httpie/issues/145#issuecomment-54704487
    set -x HTTPIE_CONFIG_DIR "$XDG_CONFIG_HOME/httpie"

    # bash
    # Folder is created in `boot.fish`
    set -x HISTFILE "$XDG_DATA_HOME/bash/history"

    # gem
    set -x GEM_HOME "$XDG_DATA_HOME/gem"
    set -x GEM_SPEC_CACHE "$XDG_CACHE_HOME/gem"

    # npm
    set -x NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/config"
    set -x NPM_CONFIG_CACHE "$XDG_CACHE_HOME/npm"

    # Wine
    set -x WINEPREFIX "$XDG_DATA_HOME/wine"

    # wget
    set -x WGETRC "$XDG_CONFIG_HOME/wget/wgetrc"

    # xauth
    set -x XAUTHORITY "$XDG_CACHE_DIR"/xauth/Xauthority

    # Bundler (Ruby)
    set -x BUNDLE_USER_CONFIG "$XDG_CONFIG_HOME"/bundle
    set -x BUNDLE_USER_CACHE  "$XDG_CACHE_HOME"/bundle
    set -x BUNDLE_USER_PLUGIN "$XDG_DATA_HOME"/bundle

    # node
    set -x NODE_REPL_HISTORY "$XDG_DATA_HOME"/node_repl_history
