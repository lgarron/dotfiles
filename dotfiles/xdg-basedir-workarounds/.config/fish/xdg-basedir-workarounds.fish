# This file contains hacks to make programs respect the XDG basedir
# specification. The main purpose of this is to get them to stop pollluting
# $HOME with dotfiles.

## Env vars

    # Explicitly set env vars to the default paths, since that will occasionally
    # get programs to behave.
    set -xg XDG_CACHE_HOME $HOME/.cache
    set -xg XDG_CONFIG_HOME $HOME/.config
    set -xg XDG_DATA_HOME $HOME/.data

## XDG workarounds for specific programs.

    set -xg LESSHISTFILE $XDG_DATA_HOME/lesshst

    # GnPG
    # See `lglogin.fish` for `launchctl setenv`
    set -xg GNUPGHOME $XDG_CONFIG_HOME/gnupg

    # HTTPie
    # Workaround from https://github.com/jakubroztocil/httpie/issues/145#issuecomment-54704487
    set -xg HTTPIE_CONFIG_DIR $XDG_CONFIG_HOME/httpie

    # bash
    # Folder is created in `lglogin.fish`
    #
    # We'd use "$XDG_DATA_HOME/bash/history", but bash won't create the
    # intermediate folder and this prevents us from having to create it
    # manually.
    set -xg HISTFILE $XDG_DATA_HOME/bash_history

    # gem
    set -xg GEM_HOME $XDG_DATA_HOME/gem
    set -xg GEM_SPEC_CACHE $XDG_CACHE_HOME/gem

    # npm
    set -xg NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/config
    set -xg npm_config_userconfig $XDG_CONFIG_HOME/npm/config
    set -xg NPM_CONFIG_CACHE $XDG_CACHE_HOME/npm

    # Wine
    set -xg WINEPREFIX $XDG_DATA_HOME/wine

    # wget
    set -xg WGETRC $XDG_CONFIG_HOME/wget/wgetrc

    # xauth
    set -xg XAUTHORITY $XDG_CACHE_DIR/xauth/Xauthority

    # Bundler (Ruby)
    set -xg BUNDLE_USER_CONFIG $XDG_CONFIG_HOME/bundle
    set -xg BUNDLE_USER_CACHE  $XDG_CACHE_HOME/bundle
    set -xg BUNDLE_USER_PLUGIN $XDG_DATA_HOME/bundle

    # node
    set -xg NODE_REPL_HISTORY $XDG_DATA_HOME/node_repl_history

    # VSCode
    # set -xg VSCODE_EXTENSIONS $XDG_DATA_HOME/vscode/extensions

    # rbenv
    # https://github.com/rbenv/rbenv/issues/811
    set -xg RBENV_ROOT $XDG_DATA_HOME/rbenv

    # zsh
    set -xg ZDOTDIR $XDG_CONFIG_HOME/zsh

    # cargo (Rust)
    set -xg CARGO_HOME $XDG_DATA_HOME/cargo

    # Docker
    set -xg DOCKER_CONFIG $XDG_CONFIG_HOME/docker
