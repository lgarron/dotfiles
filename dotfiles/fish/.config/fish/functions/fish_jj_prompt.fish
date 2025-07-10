function __fish_jj_num_commits_from_to
    command jj log 2>/dev/null \
        --no-graph \
        --ignore-working-copy \
        --color=always \
        --revisions $argv[1]".."$argv[2] \
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
    # TODO: fold into the implementation above and improve perf.
    # TODO: implement narrow viewport mode.
    # TODO: Handle when the closest bookmark/ancestor/non-empty ancestor are different lines.
    set -l closest_bookmark (
        jj guess-branch --color=always
    )
    set -l closest_bookmark_commit (
        command jj log 2>/dev/null \
            --no-graph \
            --ignore-working-copy \
            --color=always \
            --revisions "closest_ancestor_bookmark(@, 10)" \
            --template 'commit_id'
    )
    set -l closest_nonempty_ancestor_commit (
        command jj log 2>/dev/null \
            --no-graph \
            --ignore-working-copy \
            --color=always \
            --revisions "closest_nonempty_ancestor(@, 10)" \
            --template 'commit_id'
    )
    set -l closest_bookmark_to_here_distance (__fish_jj_num_commits_from_to $closest_bookmark_commit "here(10)")
    set -l here_to_nonempty_distance (__fish_jj_num_commits_from_to "here" $closest_nonempty_ancestor_commit)
    set -l nonempty_to_at_distance (__fish_jj_num_commits_from_to $closest_nonempty_ancestor_commit "@")
    set closest_bookmark_suffix " ($closest_bookmark +$closest_bookmark_to_here_distance pushable +$here_to_nonempty_distance undescribed +$nonempty_to_at_distance empty)"
    printf "%s%s" $info $closest_bookmark_suffix
end
