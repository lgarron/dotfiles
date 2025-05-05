# From https://github.com/fish-shell/fish-shell/issues/11183#issuecomment-2699601115
# Based on fish_jj_prompt and https://gist.github.com/hroi/d0dc0e95221af858ee129fd66251897e
function fish_jj_prompt
    # If jj isn't installed, there's nothing we can do
    # Return 1 so the calling prompt can deal with it
    if not command -sq jj
        return 1
    end
    set -l info "$(
        jj log 2>/dev/null --no-graph --ignore-working-copy --color=always --revisions @ \
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
            '
    )"
    or return 1
    # TODO: fold into the implementation above and improve perf.
    # TODO: implement narrow viewport mode.
    # TODO: select just the bookmark that `jj tug` would oeprate on?
    set -l closest_bookmark (
        jj log 2>/dev/null \
            --no-graph \
            --ignore-working-copy \
            --color=always \
            --revisions "closest_ancestor_bookmark(@)" \
            --template 'bookmarks.join("/")'
    )
    set -l closest_bookmark_to_here_distance (
        jj log 2>/dev/null \
            --no-graph \
            --ignore-working-copy \
            --color=always \
            --revisions "closest_ancestor_bookmark(@)..here" \
            --template "'.'" \
            | wc -c \
            | tr -d " "
    )
    set -l here_to_nonempty_distance (
        jj log 2>/dev/null \
            --no-graph \
            --ignore-working-copy \
            --color=always \
            --revisions "here..closest_nonempty_ancestor(@)" \
            --template "'.'" \
            | wc -c \
            | tr -d " "
    )
    set -l nonempty_to_at_distance (
        jj log 2>/dev/null \
            --no-graph \
            --ignore-working-copy \
            --color=always \
            --revisions "closest_nonempty_ancestor(@)..@" \
            --template "'.'" \
            | wc -c \
            | tr -d " "
    )
    set closest_bookmark_suffix " ($closest_bookmark +$closest_bookmark_to_here_distance pushable +$here_to_nonempty_distance undescribed +$nonempty_to_at_distance empty)"
    printf "%s%s" $info $closest_bookmark_suffix
end
