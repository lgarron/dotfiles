# Path

    function _add_to_path
      set NEW_PATH_COMPONENT $argv[1]
      fish_add_path --append $NEW_PATH_COMPONENT
    end

    # LSP override: This is an intentionally exported variable.
    # @fish-lsp-disable-next-line 4004
    set -x "GOPATH" "$HOME/Code/gopath"

    if [ "$_FISH_MANUAL_RELOAD" = "true" -o "$_FISH_USER_PATHS_HAS_BEEN_SET_UP" != "true" ]
      set -l _FISH_MANUAL_RELOAD_EMOJI ""
      if [ "$_FISH_MANUAL_RELOAD" = "true" ]
        echo ""
        set _FISH_MANUAL_RELOAD_EMOJI "🔄"
      end
      set -e fish_user_paths

      _add_to_path "$HOME/.cache/cargo/bin" # For Rust
      _add_to_path /opt/homebrew/bin # macOS (Apple Silicon)
      _add_to_path /home/linuxbrew/.linuxbrew/bin # for codespaces
      _add_to_path /home/linuxbrew/.linuxbrew/sbin # for codespaces
      _add_to_path "$GOPATH/bin"
      _add_to_path $HOME/.cache/.bun/bin # For zig (for building Bun) https://bun.sh/docs/project/development
      _add_to_path "/usr/local/bin"
      _add_to_path "$HOME/.shared-hosting/bin" # for Dreamhost
      _add_to_path "$HOME/.config/binaries/linux-x64" # for Codespaces

      set_color --bold
      echo -n "🐟"$_FISH_MANUAL_RELOAD_EMOJI
      echo -n " \$fish_user_paths"
      set_color normal

      if [ (count $fish_user_paths) -gt 0 ]
        echo " has been set to the following order:"
        for path in $fish_user_paths
          echo "↪ 📂$path"
        end
      else
        echo " has been reset, and contains no paths."
      end
      echo ""

      # LSP override: This is intentionally setting a universal variable to avoid running more than needed.
      # @fish-lsp-disable-next-line 2003
      set -U _FISH_USER_PATHS_HAS_BEEN_SET_UP true
    end
