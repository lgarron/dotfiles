# Path

    function add_to_path
      set NEW_PATH_COMPONENT $argv[1]
      fish_add_path --append $NEW_PATH_COMPONENT
    end

    set -x "GOPATH" "$HOME/Code/gopath"

    if [ "$_FISH_MANUAL_RELOAD" = "true" -o "$_FISH_USER_PATHS_HAS_BEEN_SET_UP" != "true" ]
      if [ "$_FISH_MANUAL_RELOAD" = "true" ]
        echo ""
      end
      set -e fish_user_paths

      add_to_path "$HOME/.cache/cargo/bin" # For Rust
      add_to_path /opt/homebrew/bin # macOS (Apple Silicon)
      add_to_path /home/linuxbrew/.linuxbrew/bin # for codespaces
      add_to_path /home/linuxbrew/.linuxbrew/sbin # for codespaces
      add_to_path "$GOPATH/bin"
      add_to_path $HOME/.cache/.bun/bin # For zig (for building Bun) https://bun.sh/docs/project/development
      add_to_path "/usr/local/bin"

      set_color --bold; echo -n "\$fish_user_paths"; set_color normal
      if [ (count $fish_user_paths) -gt 0 ]
        echo " has been set to the following order:"
        for path in $fish_user_paths
          echo "↪ 📂$path"
        end
      else
        echo " has been reset, and contains no paths."
      end
      echo ""

      set -U _FISH_USER_PATHS_HAS_BEEN_SET_UP true
    end
