# Define a subcommand argument, i.e. an argument that can only follow certain subcommands.
# For example, `git` has different arguments for each subcommand:
#
#  - git commit m⎵ → git commit --message
#  - git add p⎵ → git add --patch
#
# Example implementations:
#
#     abbr_subcommand_arg git m "--message" commit
#     abbr_subcommand_arg git p "--patch" add
#
# Multiple commands can also be specified together. For example, the following can be defined at once:
#
# - git rebase      c⎵ → git rebase      --continue
# - git merge       c⎵ → git merge       --continue
# - git cherry-pick c⎵ → git cherry-pick --continue
#
# Example implementation:
#
#     abbr_subcommand_arg git c "--continue" rebase merge cherry-pick
#
# To implement an argument for *all* subcommands of a given command, use
# `abbr_anysubcommand_arg` (see below).
function abbr_subcommand_arg
    _curry_abbr _abbr_expand_subcommand_arg $argv
end
