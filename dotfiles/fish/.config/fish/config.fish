# `config.fish`

# Setup

    # Only print if we're a TTY.
    # This prevents `protocol error: bad line length character` in git.
    function _echo
        if isatty
            if not [ $SSH_TTY ]
                echo $argv
            end
        end
    end

# Paths

    function add_to_path
      set NEW_PATH_COMPONENT $argv[1]
      fish_add_path --append $NEW_PATH_COMPONENT
      # set PATH $PATH $NEW_PATH_COMPONENT
    end

    set -x "GOPATH" "$HOME/Code/gopath"

    if [ "$MANUAL_RELOAD" = "true" -o (count $fish_user_paths) -eq 0 ]
      if [ "$MANUAL_RELOAD" = "true" ]
        _echo ""
      end
      set -e fish_user_paths

      add_to_path "$HOME/.cache/cargo/bin" # For Rust
      add_to_path /opt/homebrew/bin # macOS (Apple Silicon)
      add_to_path /home/linuxbrew/.linuxbrew/bin # for codespaces
      add_to_path /home/linuxbrew/.linuxbrew/sbin # for codespaces
      add_to_path "$GOPATH/bin"
      add_to_path "/usr/local/go/bin"
      add_to_path /opt/homebrew/opt/postgresql@15/bin
      add_to_path $HOME/.cache/.bun/bin # For zig (for building Bun) https://bun.sh/docs/project/development

      set_color --bold; _echo -n "\$fish_user_paths"; set_color normal
      echo " has been set to the following order:"
      for path in $fish_user_paths
        _echo "↪ $path"
      end
      _echo ""
    end

# Main reload message

    if [ "$MANUAL_RELOAD" = "true" ]
      _echo -n "🐟🔄 Reloading "
      set_color --bold
      _echo -n "fish"
      set_color normal
      _echo " files."
    end

# Loading

    function loading_indicator
      if [ "$MANUAL_RELOAD" = "true" ]
        _echo $argv[1]
      end
    end

    loading_indicator -n "↪ "
    loading_indicator (status --current-filename)

    function load_if_exists
      if test -f $argv[2]
        loading_indicator "  ↪ $argv[2]"
        source $argv[2]
      end
    end

# Dotfiles conveniences

    set DOTFILES_FOLDER ( \
        realpath ~/.config/fish/config.fish \
          | sed 's#dotfiles/fish/\.config/fish/config\.fish$##' \
    )

    abbr -a dff "cd $DOTFILES_FOLDER"
    abbr -a dlf "cd ~/Downloads"

    # Reloads the fish config file. `rc` is chosen because the config file for
    # other shells is often known as the `rc` file, and `rc` is easy to type.
    #
    # For this config file, `rc` will also force redefining abbreviations. See
    # the "Setup" section above.
    abbr -a rc ". $HOME/.config/fish/config.fish"
    # TODO: why is this needed? It seems that `$DOTFILES_FOLDER` is reset by something else between its original definition and here, when running in a codespace?
    if [ "$CODESPACES" = "true" ]
      set DOTFILES_FOLDER "/workspaces/.codespaces/.persistedshare/dotfiles/"
    end
    abbr -a rcu "git -C \"$DOTFILES_FOLDER\" pull ; and . $HOME/.config/fish/config.fish"
    if [ "$CODESPACES" = "true" ]
      abbr -a rcuf "cd $DOTFILES_FOLDER && git fetch origin main && git abandon && git reset --hard origin/main && cd - && . $HOME/.config/fish/config.fish"
    end

# XDG path configuration

  load_if_exists "xdg-basedir-workarounds" $HOME/.config/fish/xdg-basedir-workarounds.fish

# Machines

    set GERMAIN Germain germain Germain.local
    set PYTHAGORAS Pythagoras pythagoras Pythagoras.local

# MOTD

    function fish_greeting_echo
      for arg in $argv
        echo -n $arg | head -c(tput cols)
        echo ""
      end
      echo ""
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
    set GREETING_HOSTNAME (hostname -s)
    function fish_greeting
      if contains $GREETING_HOSTNAME $GERMAIN
        fish_greeting_echo \
            "  ___ ___ ___ __  __   _   ___ _  _ " \
            " / __| __| _ \\  \\/  | /_\\ |_ _| \\| |" \
            "| (_ | _||   / |\\/| |/ _ \\ | || .` |" \
            " \\___|___|_|_\\_|  |_/_/ \\_\\___|_|\\_|"
      else if contains $GREETING_HOSTNAME $PYTHAGORAS
        fish_greeting_echo \
          " _____   _______ _  _   _   ___  ___  ___    _   ___ " \
          "| _ \\ \\ / /_   _| || | /_\\ / __|/ _ \\| _ \\  /_\\ / __|" \
          "|  _/\\ V /  | | | __ |/ _ \\ (_ | (_) |   / / _ \\\\__ \\" \
          "|_|   |_|   |_| |_||_/_/ \\_\\___|\\___/|_|_\\/_/ \\_\\___/"
      else
        echo -n "🐟 Welcome to "
        set_color --bold; echo (hostname -s)
      end
    end

# Printing

    function echo-alternate-background
        set set_color_arg "normal"
        for arg in $argv[1..-1]
            set_color $set_color_arg
            echo -n $arg

            if [ "$set_color_arg" = "normal" ]
                set set_color_arg "-r"
            else
                set set_color_arg "normal"
            end
        end
        set_color "normal"
        echo ""
    end

    function echo-red
        set_color "red"
        echo $argv[1]
        set_color "normal"
    end

# Shortcuts

## Shell

    function mkcd
        mkdir $argv[1]
        cd $argv[1]
    end

    function resize
      if test (count $argv) -lt 3
        echo "Usage: resize 1200 630 in.png out.png"
        return 1
      end
      if test (count $argv) -lt 4
        set output (path change-extension "" $argv[3]).$argv[1]x$argv[2].png
        echo "Writing to: $output"
      else
        set output $argv[4]
      end
      convert $argv[3] -background transparent -trim -gravity Center -extent $argv[1]:$argv[2]\# -scale $argv[1]x$argv[2] $output
    end
    function square
      resize $argv[1] $argv[1] $argv[2] $argv[3]
    end
    function web-app-images
      if test (count $argv) -lt 1
        echo "Usage: web-app-images icon-source.png"
        return 1
      end
      set input $argv[1]
      set output_prefix (path change-extension "" $input)
      set temp_dir (mktemp -d)
      square 16 $input $temp_dir/$output_prefix.16px.png
      square 32 $input $temp_dir/$output_prefix.32px.png
      convert $temp_dir/$output_prefix.16px.png $temp_dir/$output_prefix.32px.png $output_prefix.favicon.ico
      echo "$output_prefix.favicon.ico"
      square 256 $input $output_prefix.app-icon.png
      echo "$output_prefix.app-icon.png"
      resize 1200 630 $input $output_prefix.social-media-preview.png
      echo "$output_prefix.social-media-preview.png"
    end

    abbr -a "date-iso-8601" "date \"+%Y-%m-%d\""

### Abbrevation definition helpers

    # For more detailed examples, see: https://github.com/fish-shell/fish-shell/issues/9411#issuecomment-1397950277

    # Define an abbreviation that can be used in any arg position.
    # For example, `make` targets can appear in any order:
    #
    # - make b⎵ → make build
    # - make c⎵ → make clean
    # - make c⎵ b⎵ → make clean build
    #
    # Example implementations:
    #
    #     function _abbr_make_build_fn; _abbr_define_anyarg build make; end
    #     abbr -a _abbr_make_build --regex b --position anywhere --function _abbr_make_build_fn
    #
    #     function _abbr_make_clean_fn; _abbr_define_anyarg clean make; end
    #     abbr -a _abbr_make_clean --regex c --position anywhere --function _abbr_make_clean_fn
    #
    function _abbr_define_anyarg
        set expansion $argv[1]
        set main_command $argv[2]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command ]
            echo $expansion
            return 0
        end
        return 1
    end

    # Define a subcommand, i.e. something that must be used as the first
    # argument to a command. For example, the `git` command is built around
    # subcommands:
    #
    # - git p⎵ → git push
    # - git m⎵ → git merge
    #
    # But:
    #
    # - git checkout m⎵ → (not expanded to `git checkout merge`)
    #
    # Example implementations:
    #
    #     function _abbr_git_push_fn; _abbr_define_subcommand push git p; end
    #     abbr -a _abbr_git_push --regex p --position anywhere --function _abbr_git_push_fn
    #
    #     function _abbr_git_merge_fn; _abbr_define_subcommand merge git m; end;
    #     abbr -a _abbr_git_merge --regex m --position anywhere --function _abbr_git_merge_fn
    #
    # To implement an argument for *all* subcommands of a given command, use
    # `_abbr_define_subcommand_arg` (see below) with an empty denylist.
    #
    function _abbr_define_subcommand
        set expansion $argv[1]
        set main_command $argv[2]
        set sub_command_abbreviation $argv[3]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command -a (count $cmd) -eq 2 -a "$cmd[2]" = $sub_command_abbreviation ]
            echo $expansion
            return 0
        end
        return 1
    end

    # Define a subcommand argument, i.e. an argument that can only follow certain subcommands.
    # For example, `git` has different arguments for each subcommand:
    #
    #  - git branch m⎵ → git branch --move
    #  - git commit m⎵ → git commit --message "%"
    #
    # Example implementations:
    #
    #     function _abbr_git_branch_move_fn; _abbr_define_subcommand_arg "--move" git branch; end;
    #     abbr -a _abbr_git_branch_move --regex m --position anywhere --function _abbr_git_branch_move_fn
    #
    #     function _abbr_git_commit_message_fn; _abbr_define_subcommand_arg "--message \"%\"" git commit; end;
    #     abbr -a _abbr_git_commit_message --regex m --position anywhere --function _abbr_git_commit_message_fn --set-cursor
    #
    # Multiple commands can also be specified together. For example, the following can be defined at once:
    #
    # - git rebase      c[space] → git rebase      --continue
    # - git merge       c[space] → git merge       --continue
    # - git cherry-pick c[space] → git cherry-pick --continue
    #
    # Example implementation:
    #
    #     set -g git_subcommands_reentrant \
    #         rebase \
    #         merge \
    #         cherry-pick
    #     function _abbr_git_reentrant_continue_fn; _abbr_define_subcommand_arg "--continue" git $git_subcommands_reentrant; end
    #     abbr -a _abbr_git_reentrant_continue --regex c --position anywhere --function _abbr_git_reentrant_continue_fn
    #
    function _abbr_define_subcommand_arg
        set expansion $argv[1]
        set main_command $argv[2]
        set sub_commands $argv[3..-1]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command ]
            if contains -- "$cmd[2]" $sub_commands
                echo $expansion
                return 0
            end
        end
        return 1
    end

    # Define a subcommand argument using a denylist. This is like
    # `_abbr_define_subcommand_arg`, but instead of allowing it as an argument
    # for the given subcommands, it will work for all subcommands *except* the
    # listed ones.
    #
    # For example, `m` → `main` is a useful branch name expansion for most `git`
    # subcommands. But it would conflict with `git commit m` → `git commit
    # --message` (see above). This function lets you exclude `git commit`
    # without having to specify a large list of `git` subcommands explicitly:
    #
    #  - git checkout m⎵ → git checkout main
    #  - git merge m⎵ → git merge main
    #  - git log m⎵ → git log main
    #
    # But:
    #
    #  - git commit m⎵ → (not expanded to `git commit main`)
    #
    # Example implementation:
    #
    #     function _abbr_git_main_fn; _abbr_define_exceptsubcommand_arg main git commit; end
    #     abbr -a _abbr_git_main --regex m --position anywhere --function _abbr_git_main_fn
    #
    function _abbr_define_exceptsubcommand_arg
        set expansion $argv[1]
        set main_command $argv[2]
        set sub_commands $argv[3..-1]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command -a (count $cmd) -gt 2 ]
            if not contains -- "$cmd[2]" $sub_commands
                echo $expansion
                return 0
            end
        end
        return 1
    end

### Editors

    # TODO: https://github.com/microsoft/vscode/issues/139634
    set -xg "VISUAL" (which code)" -w"
    set -xg "EDITOR" "code -w"
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

    abbr -a - "cd -"

    abbr -a w "brew"
    abbr -a wi "brew install"
    abbr -a wih "brew install --HEAD"
    abbr -a wr "brew reinstall"
    abbr -a wu "brew uninstall"
    abbr -a ws "brew search"
    function _abbr_brew_install_fn; _abbr_define_subcommand install brew i; end; abbr -a _abbr_brew_install --regex i --position anywhere --function _abbr_brew_install_fn
    function _abbr_brew_install_HEAD_fn; _abbr_define_subcommand_arg "--HEAD" brew install; end; abbr -a _abbr_brew_install_HEAD --regex h --position anywhere --function _abbr_brew_install_HEAD_fn
    function _abbr_brew_reinstall_fn; _abbr_define_subcommand reinstall brew r; end; abbr -a _abbr_brew_reinstall --regex r --position anywhere --function _abbr_brew_reinstall_fn
    function _abbr_brew_uninstall_fn; _abbr_define_subcommand uninstall brew u; end; abbr -a _abbr_brew_uninstall --regex u --position anywhere --function _abbr_brew_uninstall_fn
    function _abbr_brew_search_fn; _abbr_define_subcommand search brew s; end; abbr -a _abbr_brew_search --regex s --position anywhere --function _abbr_brew_search_fn
    

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

    function cd-dir
      set INPUT_PATH $argv[1]
      if not test -d $INPUT_PATH
        set INPUT_PATH (dirname $INPUT_PATH)
      end
      cd $INPUT_PATH
    end

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

# Shortcuts

    function pnice
      set NICENESS $argv[2]
      if test (count $argv) -lt 2
        echo "Usage: pnice <process substring> <niceness>"
      else
        echo "📶 Setting niceness $NICENESS for process names containing: $argv[1]";
        for pid in (pgrep $argv[1])
          echo -n "🖥  renice $NICENESS $pid"
          renice $NICENESS $pid 2> /dev/null
          if test $status -ne 0
                echo -n " (sudo)"
                sudo renice $NICENESS $pid
              end
          echo ""
        end
      end
    end

    function pnicest
      pnice $argv[1] 19
    end

    function niceplz
      # Prioritize Quicksilver.
      # I use it all the time, and it's a canary for system overload.
      pnice "Quicksilver" "-20"
      # Syncing processes.
      pnicest "Dropbox"
      pnicest "Backup and Sync"
      pnicest "Google Drive"
      pnicest "CCC User Agent"
      pnicest "CloneKitService" # Custom CCC process name prefix
      pnicest "Maestral"
      pnicest "Compressor"
      pnicest "VTEncoderXPCService" # main encoding process used by Compressor?
      pnicest "Spotlight"
      pnicest "mds_stores"
      pnicest "mdsync"
      pnicest "mdworker_shared"
      pnicest "com.carbonblack.es-loader.es-extension"
      pnicest "ArqAgent"
      pnicest "zoom.us"
      pnicest "com.apple.DriverKit.AppleUserECM" # Ethernet?
      echo "sudo for Time Machine (Ctrl-C to skip Time Machine)"
      sudo echo -n "" ; or return
      pnicest "backupd"
    end

# Screenshots

    function set-screenshot-dir
        set DIR $argv[1]
        echo-alternate-background "Setting screenshot dir to: " $DIR
        defaults write com.apple.screencapture location $DIR
        killall SystemUIServer
    end

# Includes

    load_if_exists "git" $HOME/.config/fish/git.fish
    load_if_exists "dev" $HOME/.config/fish/dev.fish

    loading_indicator ""

# Cleanup

    # From now on, reloads of this file are considered "manual".
    set MANUAL_RELOAD true
