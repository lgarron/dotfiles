# Path

    function _add_to_path
      set NEW_PATH_ENTRY $argv[1]
      if not test -d $NEW_PATH_ENTRY
        return
      end
      # We use this instead of `fish_add_path --append` so it works in `trampoline.fish`.
      set PATH $PATH $NEW_PATH_ENTRY
      if [ "$_FISH_USER_PATHS_QUIET_SETUP" != "true" -a "$_FISH_MANUAL_RELOAD" = "true" ]
        echo "  ↪ 📂 $NEW_PATH_ENTRY"
      end
    end

    # LSP override: This is an intentionally exported variable.
    # @fish-lsp-disable-next-line 4004
    # This should theoretically go in `xdg-basedir-workarounds.fish`, but we place it here so we can reference it below.
    set -x "GOPATH" "$HOME/.local/share/gopath"

    if [ "$_FISH_USER_PATHS_QUIET_SETUP" != "true" -a "$_FISH_MANUAL_RELOAD" = "true" ]
      echo ""
      echo "🐟🔄 Reloading user paths:"
    end
    set -e fish_user_paths

    _add_to_path "$HOME/.local/share/cargo/bin" # For Rust
    _add_to_path /opt/homebrew/bin # macOS (Apple Silicon)
    _add_to_path /home/linuxbrew/.linuxbrew/bin # for codespaces
    _add_to_path /home/linuxbrew/.linuxbrew/sbin # for codespaces
    _add_to_path "$GOPATH/bin"
    _add_to_path $HOME/.cache/.bun/bin # For zig (for building Bun) https://bun.sh/docs/project/development
    _add_to_path "/usr/local/bin"
    _add_to_path "$HOME/.local/share/binaries/linux-x64" # for Dreamhost and Codespaces

    if [ "$_FISH_USER_PATHS_QUIET_SETUP" != "true" -a "$_FISH_MANUAL_RELOAD" = "true" ]
      echo ""
    end
