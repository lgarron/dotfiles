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
