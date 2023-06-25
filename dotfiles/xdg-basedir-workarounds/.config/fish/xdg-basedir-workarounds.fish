# This file contains hacks to make programs respect the XDG basedir
# specification. The main purpose of this is to get them to stop pollluting
# $HOME with dotfiles.

## Env vars

    # Explicitly set env vars to the default paths, since that will occasionally
    # get programs to behave.
    set -Ux XDG_CACHE_HOME $HOME/.cache
    set -Ux XDG_CONFIG_HOME $HOME/.config
    set -Ux XDG_DATA_HOME $HOME/.data

## XDG workarounds for specific programs.

    set -Ux LESSHISTFILE $XDG_DATA_HOME/lesshst

    # GnPG
    # See `lglogin.fish` for `launchctl setenv`
    set -Ux GNUPGHOME $XDG_CONFIG_HOME/gnupg

    # HTTPie
    # Workaround from https://github.com/jakubroztocil/httpie/issues/145#issuecomment-54704487
    set -Ux HTTPIE_CONFIG_DIR $XDG_CONFIG_HOME/httpie

    # bash
    # Folder is created in `lglogin.fish`
    #
    # We'd use "$XDG_DATA_HOME/bash/history", but bash won't create the
    # intermediate folder and this prevents us from having to create it
    # manually.
    set -Ux HISTFILE $XDG_DATA_HOME/bash/history
    mkdir -p (dirname $HISTFILE) &

    # gem
    set -Ux GEM_HOME $XDG_DATA_HOME/gem
    set -Ux GEM_SPEC_CACHE $XDG_CACHE_HOME/gem

    # npm
    set -Ux NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/config
    set -Ux NPM_CONFIG_CACHE $XDG_CACHE_HOME/npm

    # Wine
    set -Ux WINEPREFIX $XDG_DATA_HOME/wine

    # wget
    set -Ux WGETRC $XDG_CONFIG_HOME/wget/wgetrc

    # xauth
    set -Ux XAUTHORITY $XDG_CACHE_DIR/xauth/Xauthority

    # Bundler (Ruby)
    set -Ux BUNDLE_USER_CONFIG $XDG_CONFIG_HOME/bundle
    set -Ux BUNDLE_USER_CACHE  $XDG_CACHE_HOME/bundle
    set -Ux BUNDLE_USER_PLUGIN $XDG_DATA_HOME/bundle

    # node
    set -Ux NODE_REPL_HISTORY $XDG_DATA_HOME/node_repl_history

    # VSCode
    # set -Ux VSCODE_EXTENSIONS $XDG_DATA_HOME/vscode/extensions

    # rbenv
    # https://github.com/rbenv/rbenv/issues/811
    set -Ux RBENV_ROOT $XDG_DATA_HOME/rbenv

    # zsh
    set -Ux ZDOTDIR $XDG_CONFIG_HOME/zsh
    mkdir -p $ZDOTDIR &

    # Python
    set -Ux PYTHONSTARTUP $XDG_CONFIG_HOME/python/pythonrc # Note: this is not the history file itself, it's a script that sets the history file.
    mkdir -p $XDG_DATA_HOME/python & # Note: this is the folder in which the history file itself is stored.

    # Rust
    set -Ux CARGO_HOME $XDG_CACHE_HOME/cargo
    set -Ux RUSTUP_HOME $XDG_CACHE_HOME/rustup

    # Docker
    set -Ux DOCKER_CONFIG $XDG_CONFIG_HOME/docker

    # Postgres
    set -Ux PSQL_HISTORY $XDG_DATA_HOME/postgres/pqsl_history
    mkdir -p (dirname "$PSQL_HISTORY") &

    # Wasmer
    set -Ux WASMER_DIR $XDG_DATA_HOME/wasmer

    # OPAM
    set -Ux OPAMROOT $XDG_DATA_HOME/opam
