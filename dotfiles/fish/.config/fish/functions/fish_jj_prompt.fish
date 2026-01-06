function __fish_jj_num_commits
    # timeout doesn't take `--` (at least on macOS), so we hope `$argv[1]` doesn't allow for an injection. 🤷
    timeout --preserve-status 1s jj log 2>/dev/null \
        --revisions $argv[1] \
        --count || return 1
end

# From https://github.com/fish-shell/fish-shell/issues/11183#issuecomment-2699601115
# Based on fish_jj_prompt and https://gist.github.com/hroi/d0dc0e95221af858ee129fd66251897e
function fish_jj_prompt
    # This doesn't work if we set it locally outside the function.
    set -l TIMED_OUT "(timed out)"
    set -l SKIPPED_DUE_TO_ENV_VAR "(skipped due to env var)"

    # If jj isn't installed, there's nothing we can do
    # Return 1 so the calling prompt can deal with it
    if not command -sq jj
        return 1
    end
    # If `jj` can't find a root, we're probably not in a `jj` repo.
    if not command jj root &>/dev/null
        return 1
    end
    set -l info op=(timeout --preserve-status 1s jj op log --limit 1 --no-graph --ignore-working-copy --color=always --template 'id.short().substr(0, 4)' 2>/dev/null || printf "%s" $TIMED_OUT)" "(
        timeout --preserve-status 1s jj log 2>/dev/null --no-graph --ignore-working-copy --color=always --revisions here \
            --template '
                    separate(
                        " ",
                        "here=" ++ change_id.shortest(),
                    )
            ' || printf "%s" $TIMED_OUT
    )" "(
        timeout --preserve-status 1s jj log 2>/dev/null --no-graph --ignore-working-copy --color=always --revisions @ \
            --template '
                    separate(
                        " ",
                        "@=" ++ change_id.shortest(),
                        "#=" ++ commit_id.shortest(),
                        if(conflict, label("conflict", "×")),
                        if(divergent, label("divergent", "??")),
                        if(hidden, label("hidden prefix", "(hidden)")),
                        if(immutable, label("node immutable", "◆")),
                        if(diff.files().len() > 0, "±files=" ++ diff.files().len())
                    )
            ' || printf "%s" $TIMED_OUT
    )
    if test $pipestatus[1] -ne 0
        return 1
    end
    # TODO: Find a semantically safe way to avoid having to run this separately.
    set -l prompt_anchor_pretty (
        timeout --preserve-status 1s jj prompt-anchor-pretty --color=always || printf "%s" $TIMED_OUT
    )
    set -l prompt_pushable_stack (__fish_jj_num_commits "prompt_pushable_stack" || printf "%s" $TIMED_OUT)
    # TODO: add heuristics for slow repos? (And also optimize queries.)
    if contains "$_FISH_PROMPT_SKIP_UNPUSHABLE" true
        set prompt_draft $SKIPPED_DUE_TO_ENV_VAR
    else
        set prompt_draft (__fish_jj_num_commits "prompt_draft" || printf "%s" $TIMED_OUT)
    end
    if contains "$_FISH_PROMPT_SKIP_BLANK" true
        set prompt_blank_fringe $SKIPPED_DUE_TO_ENV_VAR
    else
        set prompt_blank_fringe (__fish_jj_num_commits "prompt_blank_fringe" || printf "%s" $TIMED_OUT)
    end

    # TODO: if the anchor is not a bookmark, show the distance to `trunk()` / `main`.
    set anchor_suffix "$prompt_anchor_pretty" "+$prompt_pushable_stack pushable"
    if contains "$prompt_draft" "$TIMED_OUT" "$SKIPPED_DUE_TO_ENV_VAR" || [ "$prompt_draft" -gt 0 ]
        set anchor_suffix $anchor_suffix (set_color yellow)"+$prompt_draft unpushable"(set_color normal)
    end
    if contains "$prompt_blank_fringe" "$TIMED_OUT" "$SKIPPED_DUE_TO_ENV_VAR" || [ "$prompt_blank_fringe" -gt 0 ]
        set anchor_suffix $anchor_suffix (set_color brgreen)"+$prompt_blank_fringe empty"(set_color normal)
    end

    printf "%s (%s)" "$info" (string join " " -- $anchor_suffix)
end
