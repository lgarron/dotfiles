function __fish_jj_num_commits
    command jj log 2>/dev/null \
        --no-graph \
        --ignore-working-copy \
        --color=always \
        --revisions $argv[1] \
        --template "'.'" \
        | wc -c \
        | tr -d " "
end

# From https://github.com/fish-shell/fish-shell/issues/11183#issuecomment-2699601115
# Based on fish_jj_prompt and https://gist.github.com/hroi/d0dc0e95221af858ee129fd66251897e
function fish_jj_prompt
    # If jj isn't installed, there's nothing we can do
    # Return 1 so the calling prompt can deal with it
    if not command -sq jj
        return 1
    end
    set -l info (
        command jj log 2>/dev/null --no-graph --ignore-working-copy --color=always --revisions @ \
            --template '
                    separate(
                        " ",
                        "@=" ++ change_id.shortest(),
                        "#=" ++ commit_id.shortest(),
                        if(conflict, label("conflict", "×")),
                        if(divergent, label("divergent", "??")),
                        if(hidden, label("hidden prefix", "(hidden)")),
                        if(immutable, label("node immutable", "◆")),
                        coalesce(
                            if(
                                empty,
                                coalesce(
                                    if(
                                        parents.len() > 1,
                                        label("empty", "(merged)"),
                                    ),
                                    label("empty", "(empty)"),
                                ),
                            ),
                            label("description placeholder", "*")
                        )
                    )
            ' \
            | string collect
    )
    if test $pipestatus[1] -ne 0
        return 1
    end
    # TODO: Find a semantically safe way to avoid having to run this separately.
    set -l closest_bookmark_maybe_divergent (
        command jj guess-branch-maybe-divergent --color=always
    )
    set -l pushable_stack_bookhere (__fish_jj_num_commits "pushable_stack_bookhere")
    set -l draft_bookhere (__fish_jj_num_commits "draft_bookhere")
    set -l blank_fringe_bookhere (__fish_jj_num_commits "blank_fringe_bookhere")
    set closest_bookmark_suffix " ($closest_bookmark_maybe_divergent +$pushable_stack_bookhere pushable +$draft_bookhere unpushable"
    if [ "$blank_fringe_bookhere" -gt 0 ]
        set closest_bookmark_suffix $closest_bookmark_suffix" (+$blank_fringe_bookhere empty"
    end
    set closest_bookmark_suffix $closest_bookmark_suffix")"
    printf "%s%s" $info $closest_bookmark_suffix
end
