# Define a subcommand argument using a denylist. This is like
# `_abbr_expand_subcommand_arg`, but instead of allowing it as an argument
# for the given subcommands, it will work for all subcommands *except* the
# listed ones.
#
# For example, `m` → `main` is a useful branch name expansion for most `git`
# subcommands. But it would conflict with `git commit m` → `git commit
# --message` (see above). This function lets you exclude `git commit`
# without having to specify a large list of `git` subcommands explicitly:
#
#  - git checkout m⎵ → git checkout main
#  - git merge m⎵ → git merge main
#  - git log m⎵ → git log main
#
# But:
#
#  - git commit m⎵ → (not expanded to `git commit main`)
#
# Example implementation:
#
#     abbr_exceptsubcommand_arg git m main commit
#
# Note: If you combine this with the `abbr_subcommand_firstarg git m "--move" branch` example from above,
# then you can expand `git branch m⎵ m⎵` to `git branch --move main`.
function abbr_exceptsubcommand_arg
    _curry_abbr _abbr_expand_exceptsubcommand_arg $argv
end
