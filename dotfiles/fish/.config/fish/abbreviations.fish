## `Dotfiles`

    # Reloads the fish config file. `rc` is chosen because the config file for
    # other shells is often known as the `rc` file, and `rc` is easy to type.
    abbr -a rc "source $HOME/.config/fish/config.fish"

    abbr -a rcu "cd $DOTFILES_FOLDER && git pull && make fish && source $HOME/.config/fish/config.fish"
    if [ "$CODESPACES" = "true" ]
      abbr -a rcuf "cd $DOTFILES_FOLDER && git fetch origin main && git abandon && git reset --hard origin/main && cd - && make fish && source $HOME/.config/fish/config.fish"
    end
    if contains "dreamhost.com" (hostname -d)
        abbr -a rcu "git -C \"$DOTFILES_FOLDER\" pull && cd $DOTFILES_FOLDER && make dreamhost && source $HOME/.config/fish/config.fish"
      abbr -a rcuf "cd $DOTFILES_FOLDER && git fetch origin main && git abandon && git reset --hard origin/main && make dreamhost && cd - && source $HOME/.config/fish/config.fish"
    end

    abbr -a dff "cd $DOTFILES_FOLDER"

## Paths

    abbr -a "cdd" "cd-dir"

    abbr -a dlf "cd ~/Downloads"
    abbr -a - "cd -"

    abbr -a o "open-macos"
    abbr -a r "reveal-macos"

## Programs and commands

    abbr -a c "code --"
    abbr -a xc "xargs code --"

    abbr -a "cs" "command --search"
    abbr -a "csa" "command --search --all"
    abbr -a "cv" "# Try: cs"
    abbr -a "cva" "# Try: csa"
    abbr -a "which" "# Try: cs"
    abbr -a ccv --set-cursor "code -- (command -v %)"

    abbr -a "date-iso-8601" "date \"+%Y-%m-%d\""

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

    abbr -a zj "zellij"
    abbr_subcommand zellij a attach
    abbr_subcommand_arg zellij c --create attach
    abbr -a za "zellij attach --create"

## Arguments

    abbr -a _hh_abbr --regex "hh" --position anywhere -- "--help"
    abbr -a _vv_abbr --regex "vv" --position anywhere -- "--version"

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
    abbr -a "sshping" "sshping -H"

    for dns_connecting_command in ssh mosh sshping ping host iperf3
      # TODO: share abbreviation functions between these?
      abbr_anyarg $dns_connecting_command pl Pythagoras.lan
      abbr_anyarg $dns_connecting_command pw Pythagoras-ts.wyvern-climb.ts.net
      abbr_anyarg $dns_connecting_command g garron.net
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
    function abbr_brew_cc_fn; _abbr_expand_anyarg brew cc "cubing/cubing/%" commit; end; abbr -a abbr_brew_cc --regex cc --position anywhere --function abbr_brew_cc_fn --set-cursor
