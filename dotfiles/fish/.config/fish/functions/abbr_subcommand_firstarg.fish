# Define a subcommand argument that expands only if it's the *first* argument.
# This is useful for large CLIs where each subcommand essentially has "sub-subcommands". For example:
#
#  - git branch m⎵ → git branch --move
#  - git branch --move m⎵ → (not expanded to `git branch --move --move`)
#
# Example implementations:
#
#     abbr_subcommand_firstarg git m "--move" branch
#
# LSP override: This is an "exported" function (meant to be used outside this file).
function abbr_subcommand_firstarg
    _curry_abbr _abbr_expand_subcommand_firstarg $argv
end
