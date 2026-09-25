function _fish_postexec_refresh_gg_calculate_if_needed
    if _fish_is_true "$_FISH_JJ_WAS_RUN_DURING_COMMAND"
        echo -n true
    end
    echo -n false
end
