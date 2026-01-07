# This file contains hacks to make programs respect the XDG basedir
# specification. The main purpose of this is to get them to stop pollluting
# `$HOME` with dotfiles.

## Env vars

    # Explicitly set env vars to the default paths, since that will occasionally
    # get programs to behave.
    set -Ux XDG_CACHE_HOME $HOME/.cache
    set -Ux XDG_CONFIG_HOME $HOME/.config
    set -Ux XDG_DATA_HOME $HOME/.local/share
    set -Ux XDG_STATE_HOME $HOME/.local/state

## XDG workarounds for specific programs.

    set -Ux LESSHISTFILE $XDG_DATA_HOME/lesshst

    # GnuPG
    # See `lglogin.fish` for `launchctl setenv`
    set -Ux GNUPGHOME $XDG_CONFIG_HOME/gnupg

    # `bash`
    # Folder is created in `lglogin.fish`
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

    # `wget`
    set -Ux WGETRC $XDG_CONFIG_HOME/wget/wgetrc

    # `xauth`
    set -Ux XAUTHORITY $XDG_CACHE_DIR/xauth/Xauthority

    # Bundler (Ruby)
    set -Ux BUNDLE_USER_CONFIG $XDG_CONFIG_HOME/bundle
    set -Ux BUNDLE_USER_CACHE  $XDG_CACHE_HOME/bundle
    set -Ux BUNDLE_USER_PLUGIN $XDG_DATA_HOME/bundle

    # node
    set -Ux NODE_REPL_HISTORY $XDG_DATA_HOME/node_repl_history

    # VSCode
    # set -Ux VSCODE_EXTENSIONS $XDG_DATA_HOME/vscode/extensions

    # `rbenv`
    # https://github.com/rbenv/rbenv/issues/811
    set -Ux RBENV_ROOT $XDG_DATA_HOME/rbenv

    # `zsh`
    set -Ux ZDOTDIR $XDG_CONFIG_HOME/zsh
    # TODO: why does using `$ZDOTDIR` fail here? 😳
    mkdir -p $XDG_CONFIG_HOME/zsh &

    # Python
    set -Ux PYTHONSTARTUP $XDG_CONFIG_HOME/python/pythonrc # Note: this is not the history file itself, it's a script that sets the history file.
    mkdir -p $XDG_DATA_HOME/python & # Note: this is the folder in which the history file itself is stored.

    # Rust
    set -Ux CARGO_HOME $XDG_DATA_HOME/cargo
    set -Ux RUSTUP_HOME $XDG_DATA_HOME/rustup

    # Docker
    set -Ux DOCKER_CONFIG $XDG_CONFIG_HOME/docker

    # Postgres
    set -Ux PSQL_HISTORY $XDG_DATA_HOME/postgres/pqsl_history
    mkdir -p (dirname "$PSQL_HISTORY") &

    # Wasmer
    set -Ux WASMER_DIR $XDG_DATA_HOME/wasmer

    # OPAM
    set -Ux OPAMROOT $XDG_DATA_HOME/opam

    # AWS
    set -Ux AWS_SHARED_CREDENTIALS_FILE $XDG_CONFIG_HOME/aws/credentials
    set -Ux AWS_CONFIG_FILE $XDG_CONFIG_HOME/aws/config

    # ripgrep (`rg`)
    # (Doesn't have a default path, so it must be set explicitly.)
    set -Ux RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgrep/ripgrep-config.txt

# Defined in other files

    # $GOPATH