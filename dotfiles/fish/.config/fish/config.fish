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

    if status is-interactive
      echo -n -e "\r"
      echo "🐟🧪 version: "$FISH_VERSION
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
    if [ "$CODESPACES" = "true" ]
      set _DOTFILES_FOLDER "/workspaces/.codespaces/.persistedshare/dotfiles/"
    end


# XDG path configuration

    load_if_exists "xdg-basedir-workarounds" $HOME/.config/fish/xdg-basedir-workarounds.fish


# Greeting

    source $HOME/.config/fish/greeting.fish

# Shortcuts

## Shell

    function mkcd
      mkdir $argv[1]
      cd $argv[1]
    end

    # Restore the functionality of using `⌥_` to enter `—` on macOS.
    bind alt-_ "commandline -i —"

### Abbrevation definition helpers

    source $HOME/.config/fish/abbr.fish

### Editors

    # TODO: https://github.com/microsoft/vscode/issues/139634
    set -xg "VISUAL" (command -v code)" -w --"
    set -xg "EDITOR" (command -v code)" -w --"
    # set -xg EDITOR "open -b com.microsoft.VSCode"

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

    set _LATEST_CD_DIR_PATH $HOME
    function cd-dir
      set INPUT_PATH $argv[1]
      set -g _LATEST_CD_DIR_PATH $INPUT_PATH
      if not test -d $INPUT_PATH
        set INPUT_PATH (dirname $INPUT_PATH)
      end
      cd $INPUT_PATH
    end
    function cd-dir-from-iterm
      set -l NUM_DASHES (math $COLUMNS - 1)
      echo -n (set_color B594E2)"╭"
      string repeat -n $NUM_DASHES "─"
      echo "┴ Launching shell in folder for path:"
      echo ""
      echo (set_color --bold)"$argv[1]"(set_color B594E2)
      echo ""
      echo "┬ Use ^⌥R to place this into a command."
      echo -n "╰"
      string repeat -n $NUM_DASHES "─"
      echo -n (set_color normal)

      cd-dir $argv[1]
    end
    function cd-dir-from-iterm-base64
      cd-dir-from-iterm (printf %s $argv[1] | base64 --decode)
    end
    function _abbr_latest_cd_dir_path
      if not set -q _LATEST_CD_DIR_PATH
        return 1
      end
      string escape $_LATEST_CD_DIR_PATH
    end
    abbr -a _kk_abbr --regex "kk" --position anywhere --function _abbr_latest_cd_dir_path

# Includes

    load_if_exists "abbreviations" $HOME/.config/fish/abbreviations.fish
    load_if_exists "git" $HOME/.config/fish/git.fish
    load_if_exists "dev" $HOME/.config/fish/dev.fish
    load_if_exists "repo" $HOME/Code/git/github.com/lgarron/repo/repo_completions_and_abbreviations.fish # TODO: configure this load statically

    loading_indicator ""

# Cleanup

    # From now on, reloads of this file are considered "manual".
    set _FISH_MANUAL_RELOAD true
