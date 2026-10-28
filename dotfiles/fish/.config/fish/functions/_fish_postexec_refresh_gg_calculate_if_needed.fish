function _fish_postexec_refresh_gg_calculate_if_needed
    # Maybe someday: https://github.com/gulbanana/gg/discussions/70
    if _fish_is_true "$CODESPACES"
        echo -n false
        return
    end
    if _fish_is_true "$_FISH_JJ_WAS_RUN_DURING_COMMAND"
        echo -n true
        return
    end
    echo -n false
end
