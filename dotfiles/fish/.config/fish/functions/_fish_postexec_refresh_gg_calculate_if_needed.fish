function _fish_postexec_refresh_gg_calculate_if_needed
    if _fish_is_true "$_FISH_JJ_WAS_RUN_DURING_COMMAND"
        if not _fish_is_true "$_FISH_OVERRIDE_DO_NOT_RUN_GG_REFRESH_IN_POSTEXEC"
            echo -n true
            return
        end
    end
    echo -n false
end
