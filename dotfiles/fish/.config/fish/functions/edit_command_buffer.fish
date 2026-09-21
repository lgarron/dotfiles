if not functions --query __builtin_edit_command_buffer
    # The `__builtin_edit_command_buffer` implementation is self-contained (as of 2025-11-04), so this preserves semantics.
    functions --copy edit_command_buffer __builtin_edit_command_buffer
    # Workaround for https://github.com/fish-shell/fish-shell/issues/11966
    function edit_command_buffer
        set -x VISUAL (command -v code)
        # This is created above.
        # @fish-lsp-disable-next-line
        __builtin_edit_command_buffer
    end
end
