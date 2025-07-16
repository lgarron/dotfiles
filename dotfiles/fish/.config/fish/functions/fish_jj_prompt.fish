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
                    )
            ' \
            | string collect
    )
    if test $pipestatus[1] -ne 0
        return 1
    end
    # TODO: Find a semantically safe way to avoid having to run this separately.
    set -l prompt_anchor_pretty (
        command jj prompt-anchor-pretty --color=always
    )
    set -l prompt_pushable_stack (__fish_jj_num_commits "prompt_pushable_stack")
    set -l prompt_draft (__fish_jj_num_commits "prompt_draft")
    set -l prompt_blank_fringe (__fish_jj_num_commits "prompt_blank_fringe")

    # TODO: if the anchor is not a bookmark, show the distance to `trunk()` / `main`.
    set anchor_suffix "$prompt_anchor_pretty" "+$prompt_pushable_stack pushable"
    if [ "$prompt_draft" -gt 0 ]
        set anchor_suffix $anchor_suffix (set_color yellow)"+$prompt_draft unpushable"(set_color normal)
    end
    if [ "$prompt_blank_fringe" -gt 0 ]
        set anchor_suffix $anchor_suffix (set_color brgreen)"+$prompt_blank_fringe empty"(set_color normal)
    end

    printf "%s (%s)" $info (string join " " -- $anchor_suffix)
end
