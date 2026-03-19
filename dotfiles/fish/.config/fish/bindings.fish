# Bindings

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

    if contains -- "$TERM_PROGRAM" vscode "iTerm.app"
      # Legacy bindings
      bind alt-b backward-word
      bind alt-f forward-word
      bind ctrl-w backward-kill-word
      bind alt-d kill-word

      # Legacy bindings
      bind ctrl-h backward-kill-token

      # *sigh*
      # https://github.com/microsoft/vscode/issues/183268
      bind ctrl-up history-token-search-backward
    end

    # Workaround for https://github.com/zellij-org/zellij/issues/3852
    if not contains -- "$ZELLIJ_SESSION_NAME" "" > /dev/null
      bind ctrl-h backward-kill-token
    end

    function _add_LATEST_CD_DIR_PATH
      commandline --insert (string escape $_LATEST_CD_DIR_PATH)
    end
    bind ctrl-alt-r _add_LATEST_CD_DIR_PATH

    # Use ⇧⌥' (⌥") to enter `\"`
    bind alt-\" "commandline -i '\\\"'"

# VS Code shell input workarounds

    bind alt-shift-— "commandline -i —"
    bind alt-shift-Æ "commandline -i '\\\"'"
    bind alt-≈ "commandline -i '≈'"
