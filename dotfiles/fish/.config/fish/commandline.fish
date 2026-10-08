# `cd-dir`

set _LATEST_CD_DIR_PATH $HOME
function _abbr_latest_cd_dir_path
    if not set -q _LATEST_CD_DIR_PATH
        return 1
    end
    string escape $_LATEST_CD_DIR_PATH
end
abbr -a _kk_abbr --regex kk --position anywhere --function _abbr_latest_cd_dir_path

abbr -a t --position command "📋"
abbr -a tt --position anywhere --function tt_paste

# This cannot be defined in a `functions` file, since it needs access to the previous `edit_command_buffer` implementation.
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
