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

    if string match --entire -- "$TERM_PROGRAM" vscode > /dev/null
      # Legacy bindings
      bind alt-b backward-word
      bind alt-f forward-word
      bind ctrl-w backward-kill-word
      bind alt-d kill-word

      # Legacy bindings
      bind ctrl-h backward-kill-token
    end

    # Workaround for https://github.com/zellij-org/zellij/issues/3852
    if not string match --entire -- "$ZELLIJ_SESSION_NAME" "" > /dev/null
      bind ctrl-h backward-kill-token
    end

    function _add_LATEST_CD_DIR_PATH
      commandline --insert (string escape $_LATEST_CD_DIR_PATH)
    end
    bind ctrl-alt-r _add_LATEST_CD_DIR_PATH

    # Restore the functionality of using `⌥_` to enter `—` on macOS.
    bind alt-_ "commandline -i —"
    # Use ⌥' to enter `\"`
    bind alt-\' "commandline -i '\\\"'"
