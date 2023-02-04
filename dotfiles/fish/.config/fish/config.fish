# `config.fish`

# Setup

    function append_to_path_if_exists
      set NEW_PATH_COMPONENT $argv[1]
      if test -d $NEW_PATH_COMPONENT
        set PATH $PATH $NEW_PATH_COMPONENT
      end
    end

    function prepend_to_path_if_exists
      set NEW_PATH_COMPONENT $argv[1]
      if test -d $NEW_PATH_COMPONENT
        set PATH $NEW_PATH_COMPONENT $PATH
      end
    end

    append_to_path_if_exists /opt/homebrew/bin # macOS (Apple Silicon)
    append_to_path_if_exists /home/linuxbrew/.linuxbrew/bin # for codespaces
    append_to_path_if_exists /home/linuxbrew/.linuxbrew/sbin # for codespaces
    prepend_to_path_if_exists $HOME/.data/rbenv/shims # rbenv https://github.com/rbenv/rbenv#how-rbenv-hooks-into-your-shell

# Temporary workaround for a bug in Codespaces

    if test -z "$(code --version)"
      set CODE_VERSION 97dec172d3256f8ca4bfb2143f3f76b503ca0534
      echo "Patching VS CODE PATHS for VS Code $CODE_VERSION"
      fish_add_path -P /vscode/bin/linux-x64/$CODE_VERSION/bin/
      fish_add_path -P /vscode/bin/linux-x64/$CODE_VERSION/bin/remote-cli/
      fish_add_path -P /vscode/bin/linux-x64/$CODE_VERSION/bin/helpers/
      echo $PATH
    end

# Relaunch

    # VSCode shell integration
    # https://github.com/microsoft/vscode/issues/139400
    string match -q $TERM_PROGRAM vscode; and which code-insiders > /dev/null; and . (code-insiders --locate-shell-integration-path fish)

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

    if [ "$MANUAL_RELOAD" = "true" ]
      _echo ""
      _echo -n "🐟🔄 Reloading "
      set_color --bold
      _echo -n "fish"
      set_color normal
      _echo " files."
      _echo ""
    end

    # Reloads the fish config file. `rc` is chosen because the config file for
    # other shells is often known as the `rc` file, and `rc` is easy to type.
    #
    # For this config file, `rc` will also force redefining abbreviations. See
    # the "Setup" section above.
    abbr -a rc ". $HOME/.config/fish/config.fish"
    abbr -a rcu "cd $DOTFILES_FOLDER && git pull && cd - && . $HOME/.config/fish/config.fish"
    if [ "$CODESPACES" = "true" ]
      abbr -a rcuf "cd $DOTFILES_FOLDER && git fetch origin main && git abandon && git reset --hard origin/main && cd - && . $HOME/.config/fish/config.fish"
    end

# Loading

    function loading_indicator
      if [ "$MANUAL_RELOAD" = "true" ]
        _echo $argv[1]
      end
    end

    loading_indicator (status --current-filename)

    function load_if_exists
      if test -f $argv[2]
        loading_indicator "↪ $argv[2]"
        source $argv[2]
      end
    end

# XDG path configuration

  load_if_exists "xdg-basedir-workarounds" $HOME/.config/fish/xdg-basedir-workarounds.fish

# Machines

    set EUCLID Euclid euclid Euclid.local
    set GALOIS Galois galois Galois.local
    set GERMAIN Germain germain Germain.local
    set MINITEMP Minitemp minitemp Minitemp.local
    set PYTHAGORAS Pythagoras pythagoras Pythagoras.local

# MOTD

    function fish_greeting_echo
      for arg in $argv
        echo -n $arg | head -c(tput cols)
        echo ""
      end
      echo ""
    end

    # Based on: https://patorjk.com/software/taag/#p=display&v=1&f=Small&t=GALOIS
    function fish_greeting
      if contains (hostname -s) $GALOIS
        fish_greeting_echo \
            "  ___   _   _    ___ ___ ___ " \
            " / __| /_\\ | |  / _ \\_ _/ __|" \
            "| (_ |/ _ \\| |_| (_) | |\\__ \\" \
            " \\___/_/ \\_\\____\\___/___|___/"
      else if contains (hostname -s) $EUCLID
        fish_greeting_echo \
            " ___ _   _  ___ _    ___ ___  " \
            "| __| | | |/ __| |  |_ _|   \\ " \
            "| _|| |_| | (__| |__ | || |) |" \
            "|___|\\___/ \\___|____|___|___/ "
      else if contains (hostname -s) $GERMAIN
        fish_greeting_echo \
            "  ___ ___ ___ __  __   _   ___ _  _ " \
            " / __| __| _ \\  \\/  | /_\\ |_ _| \\| |" \
            "| (_ | _||   / |\\/| |/ _ \\ | || .` |" \
            " \\___|___|_|_\\_|  |_/_/ \\_\\___|_|\\_|"
      else if contains (hostname -s) $PYTHAGORAS
        fish_greeting_echo \
          " _____   _______ _  _   _   ___  ___  ___    _   ___ " \
          "| _ \\ \\ / /_   _| || | /_\\ / __|/ _ \\| _ \\  /_\\ / __|" \
          "|  _/\\ V /  | | | __ |/ _ \\ (_ | (_) |   / / _ \\\\__ \\" \
          "|_|   |_|   |_| |_||_/_/ \\_\\___|\\___/|_|_\\/_/ \\_\\___/"
      else if contains (hostname -s) $MINITEMP
        fish_greeting_echo \
            " __  __ ___ _  _ ___ _____ ___ __  __ ___ " \
            "|  \\/  |_ _| \\| |_ _|_   _| __|  \\/  | _ \\" \
            "| |\\/| || || .` || |  | | | _|| |\\/| |  _/" \
            "|_|  |_|___|_|\\_|___| |_| |___|_|  |_|_|  "
      #else if [ $CODESPACES = true ]
      #  fish_greeting_echo \
      #      "  ___ ___  ___  ___ ___ ___  _   ___ ___ ___ " \
      #      " / __/ _ \\|   \\| __/ __| _ \\/_\\ / __| __/ __|" \
      #      "| (_| (_) | |) | _|\\__ \\  _/ _ \\ (__| _|\\__ \\" \
      #      " \\___\\___/|___/|___|___/_|/_/ \\_\\___|___|___/"
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

    set DOTFILES_FOLDER ( \
        realpath ~/.config/fish/config.fish \
          | sed 's#dotfiles/fish/\.config/fish/config\.fish$##' \
    )
    abbr -a dff $DOTFILES_FOLDER

    function mkcd
        mkdir $argv[1]
        cd $argv[1]
    end

### Abbrevation definition helpers

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

    function f
      find . -iname "*$argv[1]*"
    end

    abbr -a rgnh "rg -S --no-heading"

## General

    # abbr -a t "tee >(pbcopy)"
    function t
        cat > /tmp/pbcopy.txt
        cat /tmp/pbcopy.txt
        cat /tmp/pbcopy.txt | pbcopy
        rm /tmp/pbcopy.txt
    end

    function o
        if [ (count $argv) = 0 ]
            open .
        else
            open $argv
        end
    end

    abbr -a r "open -R"

    abbr -a bi "brew install"

    abbr -a serve "open http://localhost:8000; caddy file-server --listen :8000 --browse"

    abbr -a "md5" "openssl dgst -md5"
    abbr -a "sha1" "openssl dgst -sha1"
    abbr -a "sha256" "openssl dgst -sha256"
    abbr -a "sha512" "openssl dgst -sha512"

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
    load_if_exists "go" $HOME/.config/fish/go.fish

    loading_indicator ""

# Cleanup

    # From now on, reloads of this file are considered "manual".
    set MANUAL_RELOAD true

    # Manual workaround for bun, until one of the following is resolved:
    # - https://github.com/oven-sh/bun/issues/272
    # - https://github.com/oven-sh/bun/issues/965
    append_to_path_if_exists $HOME/.local/bin
