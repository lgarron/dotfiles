function _fish_postexec_refresh_gg_if_needed
    # Maybe someday: https://github.com/gulbanana/gg/discussions/70
    if [ "$CODESPACES" = true ]
        return
    end
    if _fish_is_true "$_FISH_JJ_WAS_RUN_DURING_COMMAND"
        if command -qv gg-refresh
            if _fish_strings_are_identical $argv[1] --fancy
                # Overflowing is unlikely and not the end of the world, so allow it in order to get unbuffered `gg-refresh` output.
                echo -n "├─ "
            end
            pgrep "^gg\$" &>/dev/null && /Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/app-tools/gg-refresh.applescript
            echo "🔄 Refreshed `gg`."
        else
            echo "⚠️ Could not refresh `gg`."
        end
    end
end
