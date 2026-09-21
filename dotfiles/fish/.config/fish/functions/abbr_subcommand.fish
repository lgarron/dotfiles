# Define a subcommand, i.e. something that must be used as the first
# argument to a command. For example, the `git` command is built around
# subcommands:
#
# - git p⎵ → git push
# - git m⎵ → git merge
#
# But:
#
# - git checkout m⎵ → (not expanded to `git checkout merge`)
#
# Example implementations:
#
#     abbr_subcommand git p push
#     abbr_subcommand git m merge
#
# LSP override: This is an "exported" function (meant to be used outside this file).
function abbr_subcommand
    _curry_abbr _abbr_expand_subcommand $argv
end
