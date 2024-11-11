## `Dotfiles`

    # Reloads the fish config file. `rc` is chosen because the config file for
    # other shells is often known as the `rc` file, and `rc` is easy to type.
    #
    # For this config file, `rc` will also force redefining abbreviations. See
    # the "Setup" section above.
    abbr -a rc ". $HOME/.config/fish/config.fish"
    # TODO: why is this needed? It seems that `$_DOTFILES_FOLDER` is reset by something else between its original definition and here, when running in a codespace?

    abbr -a rcu "git -C \"$_DOTFILES_FOLDER\" pull ; and . $HOME/.config/fish/config.fish"
    if [ "$CODESPACES" = "true" ]
      abbr -a rcuf "cd $_DOTFILES_FOLDER && git fetch origin main && git abandon && git reset --hard origin/main && cd - && . $HOME/.config/fish/config.fish"
    end

    abbr -a dff "cd $_DOTFILES_FOLDER"

## Paths

    abbr -a "cdd" "cd-dir"

    abbr -a dlf "cd ~/Downloads"
    abbr -a - "cd -"

    abbr -a r "open -R"
    abbr -a r. "open -R ."

## Programs and commands

    abbr -a c "code"
    abbr -a xc "xargs code"

    abbr -a "cv" "command -v"
    abbr -a "cva" "command -va"
    abbr -a "which" "# Try: cv"
    abbr -a ccv --set-cursor "code (command -v %)"

    abbr -a "date-iso-8601" "date \"+%Y-%m-%d\""

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

    abbr -a zj "zellij"
    abbr_subcommand zellij a attach

## Arguments

    abbr -a _hh_abbr --regex "hh" --position anywhere -- "--help"

    abbr_anyarg hevc q "--quality"
    abbr_anyarg hevc f "--force-bit-depth"

    abbr_anyarg fish p "--private"

## Search

    functions -e f # Delete any old function
    abbr -a f --set-cursor "find . -iname \"*%*\""

    abbr -a rgnh "rg -S --no-heading"

## SSH

    abbr -a s "ssh"
    abbr -a "sp" "sshping -H"

    for ssh_like_command in ssh mosh sshping
      # TODO: share abbreviation functions between these?
      abbr_anyarg $ssh_like_command pt Pythagoras.tlb
      abbr_anyarg $ssh_like_command pw Pythagoras-ts.wyvern-climb.ts.net
    end

## Homebrew

    abbr -a w "brew"
    abbr -a wi "brew install"
    abbr -a win "brew info"
    abbr -a wih "brew install --HEAD"
    abbr -a wr "brew reinstall"
    abbr -a wu "# try: `wun` (brew uninstall) or `wup` (brew upgrade)"
    abbr -a wun "brew uninstall"
    abbr -a wup "brew upgrade"
    abbr -a ws "brew search"
    abbr_subcommand brew i install
    abbr_subcommand brew in info
    abbr_subcommand_arg brew h --HEAD install
    abbr_subcommand brew r reinstall
    abbr_subcommand brew u "# try: `w un` (brew uninstall) or `w up` (brew upgrade)"
    abbr_subcommand brew un uninstall
    abbr_subcommand brew up upgrade
    abbr_subcommand brew s search

    # Expand `lgarron/lgarron` tap args.
    function abbr_brew_l_fn; _abbr_expand_anyarg brew l "--HEAD lgarron/lgarron/%" commit; end; abbr -a abbr_brew_l --regex l --position anywhere --function abbr_brew_l_fn --set-cursor
    function abbr_brew_ll_fn; _abbr_expand_anyarg brew ll "lgarron/lgarron/%" commit; end; abbr -a abbr_brew_ll --regex ll --position anywhere --function abbr_brew_ll_fn --set-cursor
