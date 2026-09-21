# Define an abbreviation that can be used in any arg position.
# For example, `make` targets can appear in any order:
#
# - make b⎵ → make build
# - make c⎵ → make clean
# - make c⎵ b⎵ → make clean build
#
# Example implementations:
#
#     abbr_anyarg make b build
#     abbr_anyarg make c clean
#
function abbr_anyarg
    _curry_abbr _abbr_expand_anyarg $argv
end
