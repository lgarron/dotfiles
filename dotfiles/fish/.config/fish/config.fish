# `config.fish`

# Setup

    # Only print if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    if isatty
      if not status is-interactive
        echo "WARNING: Loaded `config.fish` outside an interactive shell. This may be due to a script shebang: https://github.com/fish-shell/fish-shell/issues/5394"
      end
      function _echo
        echo $argv
      end
    else
        function _echo; end
    end

# fish 4.0 experimentation for token nav

    set -l _FISH_MASTER_BIN_FOLDER "$HOME/.fish-master/bin"
    if status is-interactive
      if not string match --entire "$_EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null && string match --entire "$FISH_VERSION" "3.7.1" > /dev/null
        set -x _EXPERIMENTAL_FISH_LAUNCHED true
        if test -f $_FISH_MASTER_BIN_FOLDER/fish
          echo -n -e "\r"
          echo "🐟🧪 Launching experimental fish…"
          $_FISH_MASTER_BIN_FOLDER/fish
          set _EXPERIMENTAL_FISH_LAUNCHED false
          echo "Press Ctrl-D again to exit, or continue to stay in in 3.7.1"
        end
      else
        echo -n -e "\r"
        echo "🐟🧪 version: "$FISH_VERSION
        set PATH $_FISH_MASTER_BIN_FOLDER $PATH
      end
    end

    # These bindings depend on `CSI u` support.
    bind alt-left backward-word
    bind alt-right forward-word
    bind alt-backspace backward-kill-word
    bind alt-delete kill-word
    bind alt-\\ kill-word

    bind ctrl-left backward-token
    bind ctrl-right forward-token
    bind ctrl-backspace backward-kill-token
    bind ctrl-delete kill-token
    bind ctrl-\\ kill-token

    if string match --entire -- $TERM_PROGRAM vscode > /dev/null
      # Legacy bindings
      bind alt-b backward-word
      bind alt-f forward-word
      bind ctrl-w backward-kill-word
      bind alt-d kill-word

      # Legacy bindings
      bind ctrl-h backward-kill-token
    end

    function _add_LATEST_CD_DIR_PATH
      commandline --insert (string escape $_LATEST_CD_DIR_PATH)
    end
    bind ctrl-alt-r _add_LATEST_CD_DIR_PATH
    bind alt-r _add_LATEST_CD_DIR_PATH

# Paths

    function add_to_path
      set NEW_PATH_COMPONENT $argv[1]
      fish_add_path --append $NEW_PATH_COMPONENT
    end

    set -x "GOPATH" "$HOME/Code/gopath"

    if [ "$_FISH_MANUAL_RELOAD" = "true" -o "$_FISH_USER_PATHS_HAS_BEEN_SET_UP" != "true" ]
      if [ "$_FISH_MANUAL_RELOAD" = "true" ]
        _echo ""
      end
      set -e fish_user_paths

      add_to_path "$HOME/.cache/cargo/bin" # For Rust
      add_to_path /opt/homebrew/bin # macOS (Apple Silicon)
      add_to_path /home/linuxbrew/.linuxbrew/bin # for codespaces
      add_to_path /home/linuxbrew/.linuxbrew/sbin # for codespaces
      add_to_path "$GOPATH/bin"
      add_to_path $HOME/.cache/.bun/bin # For zig (for building Bun) https://bun.sh/docs/project/development
      add_to_path "/usr/local/bin"

      set_color --bold; _echo -n "\$fish_user_paths"; set_color normal
      if [ (count $fish_user_paths) -gt 0 ]
        _echo " has been set to the following order:"
        for path in $fish_user_paths
          _echo "↪ 📂$path"
        end
      else
        _echo " has been reset, and contains no paths."
      end
      _echo ""

      set -U _FISH_USER_PATHS_HAS_BEEN_SET_UP true
    end

# Completions

    if [ "$_FISH_MANUAL_RELOAD" = "true" -o "$_FISH_MANUAL_COMPLETIONS_HAVE_BEEN_SET_UP" != "true" ]
      if [ "$_FISH_MANUAL_RELOAD" = "true" ]
        _echo "Loading completions for Rust binaries and scripts…"
      end

      function _rust_completion
        set -l COMMAND $argv[1]
        set -l COMMAND_COMPLETIONS_FILE_PATH $HOME/.config/fish/completions/$COMMAND.fish
        _echo "↪ 🦀 $COMMAND"
        if command -v $COMMAND > /dev/null
          command $COMMAND --completions fish 2>/dev/null > $COMMAND_COMPLETIONS_FILE_PATH # TODO: do we need to account for path traversal?
        else
          rm -f $COMMAND_COMPLETIONS_FILE_PATH
        end
      end

      # TODO: figure out how to move all of these to Homebrew
      _rust_completion wat
      _rust_completion openscad-auto

      _echo ""

      set -U _FISH_MANUAL_COMPLETIONS_HAVE_BEEN_SET_UP true
    end

# Main reload message

    if [ "$_FISH_MANUAL_RELOAD" = "true" ]
      _echo -n "🐟🔄 Reloading "
      set_color --bold
      _echo -n "fish"
      set_color normal
      _echo " files."
    end

# Loading

    function loading_indicator
      if [ "$_FISH_MANUAL_RELOAD" = "true" ]
        _echo $argv[1]
      end
    end

    loading_indicator "↪ "(status --current-filename)

    function load_if_exists
      if test -f $argv[2]
        loading_indicator "  ↪ 🐟 $argv[2]"
        source $argv[2]
      end
    end

# Dotfiles conveniences

    set _DOTFILES_FOLDER ( \
        realpath ~/.config/fish/config.fish \
          | sed 's#dotfiles/fish/\.config/fish/config\.fish$##' \
    )

    abbr -a dff "cd $_DOTFILES_FOLDER"

    # Reloads the fish config file. `rc` is chosen because the config file for
    # other shells is often known as the `rc` file, and `rc` is easy to type.
    #
    # For this config file, `rc` will also force redefining abbreviations. See
    # the "Setup" section above.
    abbr -a rc ". $HOME/.config/fish/config.fish"
    # TODO: why is this needed? It seems that `$_DOTFILES_FOLDER` is reset by something else between its original definition and here, when running in a codespace?
    if [ "$CODESPACES" = "true" ]
      set _DOTFILES_FOLDER "/workspaces/.codespaces/.persistedshare/dotfiles/"
    end
    abbr -a rcu "git -C \"$_DOTFILES_FOLDER\" pull ; and . $HOME/.config/fish/config.fish"
    if [ "$CODESPACES" = "true" ]
      abbr -a rcuf "cd $_DOTFILES_FOLDER && git fetch origin main && git abandon && git reset --hard origin/main && cd - && . $HOME/.config/fish/config.fish"
    end

# XDG path configuration

  load_if_exists "xdg-basedir-workarounds" $HOME/.config/fish/xdg-basedir-workarounds.fish

# Machines

    set -l GERMAIN Germain germain Germain.local
    set -l PYTHAGORAS Pythagoras pythagoras Pythagoras.local

# MOTD

    function fish_greeting_echo
      for arg in $argv
        string shorten --max $COLUMNS $arg
      end
    end

    # If `hostname -s` is incorrect on macOS:
    #
    # 1. `dscacheutil -flushcache`
    # 2. Reboot
    #
    # Alternatively, use:
    #
    #     set MAC_HOSTNAME (which scutil > /dev/null && scutil --get ComputerName)
    #
    # https://apple.stackexchange.com/a/53042

    # Based on: https://patorjk.com/software/taag/#p=display&v=1&f=Small&t=GALOIS
    set -l _CURRENT_HOSTNAME (hostname -s)
    if contains $_CURRENT_HOSTNAME $GERMAIN
      function fish_greeting
        set_color B594E2
        echo -n -e "\r" # Clear any pending typed text (it will still be passed to the next prompt).
        fish_greeting_echo \
          "╭──                                          ──╮" \
          "│ ╭────╮╭────╮╭────╮╭─╮  ╭─╮╭────╮╭───╮╭──╮╭─╮ │" \
          "│ │ ╭──┤│ ──┬╯│ ⊂⊃ ││  \/  ││ ⊂⊃ │╰╮ ╭╯│  ╰╮ │ │" \
          "│ │ ╰─ ││ ──┴╮│ \ \╯│ │\/│ ││ ╭╮ │╭╯ ╰╮│ ╰╮  │ │" \
          "│ ╰────╯╰────╯╰─╯╰─╯╰─╯  ╰─╯╰─╯╰─╯╰───╯╰─╯╰──╯ │" \
          "╰──                                          ──╯"
      end
    else if contains $_CURRENT_HOSTNAME $PYTHAGORAS
      set -g _FISH_LCARS_BOTTOM 44CCAA
      set -g _FISH_LCARS_TOP 66AAFF
      function fish_greeting
        set_color 66AAFF
        echo -n -e "\r" # Clear any pending typed text (it will still be passed to the next prompt).
        fish_greeting_echo \
          "╭──                                                              ──╮" \
          "│  ╭────╮╭─╮ ╭─╮╭─────╮╭─╮╭─╮╭────╮╭────╮╭────╮╭────╮╭────╮╭────╮  │" \
          "│  │ ⊂⊃ ││ ╰─╯ │╰─╮ ╭─╯│ ╰╯ ││ ⊂⊃ ││ ╭──┤│ ╭╮ ││ ⊂⊃ ││ ⊂⊃ ││  ──┤  │" \
          "│  │ ╭──╯╰─╮ ╭─╯  │ │  │ ╭╮ ││ ╭╮ ││ ╰─ ││ ╰╯ ││ \ \╯│ ╭╮ │├──  │  │" \
          "│  ╰─╯     ╰─╯    ╰─╯  ╰─╯╰─╯╰─╯╰─╯╰────╯╰────╯╰─╯╰─╯╰─╯╰─╯╰────╯  │" \
          "╰──                                                              ──╯"
      end
    else
      set -g _FISH_LCARS_BOTTOM 888888
      set -g _FISH_LCARS_TOP 888888
      function fish_greeting
        echo -n "🐟 Welcome to "
        set_color --bold; echo (hostname -s)
      end
    end

# Shortcuts

## Shell

    function mkcd
      mkdir $argv[1]
      cd $argv[1]
    end

    abbr -a "date-iso-8601" "date \"+%Y-%m-%d\""
    abbr -a "cv" "command -v"
    abbr -a "cva" "command -va"
    abbr -a "which" "# Try: cv"

### Abbrevation definition helpers

    source $HOME/.config/fish/abbr.fish

### Editors

    # TODO: https://github.com/microsoft/vscode/issues/139634
    set -xg "VISUAL" (command -v code)" -w"
    set -xg "EDITOR" (command -v code)" -w"
    # set -xg EDITOR "open -b com.microsoft.VSCode"

    abbr -a c "code"
    abbr -a xc "xargs code"

## Search

    functions -e f # Delete any old function
    abbr -a f --set-cursor "find . -iname \"*%*\""

    abbr -a rgnh "rg -S --no-heading"

## General

    # abbr -a t "tee >(pbcopy)"
    function 📋
      cat > /tmp/pbcopy.txt
      cat /tmp/pbcopy.txt
      cat /tmp/pbcopy.txt | pbcopy
      rm /tmp/pbcopy.txt
    end
    abbr -a t "📋"

    function o
      if [ (count $argv) = 0 ]
        open .
      else
        open $argv
      end
    end

    abbr -a r "open -R"
    abbr -a r. "open -R ."

    abbr -a - "cd -"

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

    abbr -a dlf "cd ~/Downloads"

    set _LATEST_CD_DIR_PATH $HOME
    function cd-dir
      set INPUT_PATH $argv[1]
      set -g _LATEST_CD_DIR_PATH $INPUT_PATH
      if not test -d $INPUT_PATH
        set INPUT_PATH (dirname $INPUT_PATH)
      end
      cd $INPUT_PATH
    end
    abbr -a "cdd" "cd-dir"
    function cd-dir-from-iterm
      set -l NUM_DASHES (math $COLUMNS - 1)
      echo -n (set_color B594E2)"╭"
      string repeat -n $NUM_DASHES "─"
      echo "┴ Launching shell in folder for path:"
      echo ""
      echo (set_color --bold)"$argv[1]"(set_color B594E2)
      echo ""
      echo "┬ Use ^⇧R to place this into a command."
      echo -n "╰"
      string repeat -n $NUM_DASHES "─"
      echo -n (set_color normal)

      cd-dir $argv[1]
    end
    function _abbr_latest_cd_dir_path
      if not set -q _LATEST_CD_DIR_PATH
        return 1
      end
      string escape $_LATEST_CD_DIR_PATH
    end
    abbr -a _kk_abbr --regex "kk" --position anywhere --function _abbr_latest_cd_dir_path

    abbr -a _hh_abbr --regex "hh" --position anywhere -- "--help"
    abbr -a ccv --set-cursor "code (command -v %)"

    abbr -a s "ssh"
    abbr -a "sp" "sshping -H"
    for ssh_like_command in ssh mosh sshping
      # TODO: share abbreviation functions between these?
      abbr_anyarg $ssh_like_command pt Pythagoras.tlb
      abbr_anyarg $ssh_like_command pw Pythagoras-ts.wyvern-climb.ts.net
    end

    abbr_anyarg hevc q "--quality"
    abbr_anyarg hevc f "--force-bit-depth"

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

## Keyboard

    # https://developer.apple.com/library/content/technotes/tn2450/_index.html
    # Caps Lock (0x39) -> Delete Key (0x2A)
    # Insert (0x49) -> Fn key (0x03 in table 0xFF)
    function remap-keys
      hidutil property --set '{"UserKeyMapping":[
        {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x070000002A},
        {"HIDKeyboardModifierMappingSrc":0x700000049,"HIDKeyboardModifierMappingDst":0xFF00000003},
      ]}'
    end

    function remap-keys-reset
        hidutil property --set '{"UserKeyMapping":[]}'
    end

    function remap-keys-show
        hidutil property --get "UserKeyMapping"
    end

# Screenshots

    function set-screenshot-dir
      set DIR $argv[1]
      echo "Setting screenshot dir to: $DIR"
      defaults write com.apple.screencapture location $DIR
      killall SystemUIServer
    end

# Includes

    load_if_exists "git" $HOME/.config/fish/git.fish
    load_if_exists "dev" $HOME/.config/fish/dev.fish

    loading_indicator ""

# Cleanup

    # From now on, reloads of this file are considered "manual".
    set _FISH_MANUAL_RELOAD true
