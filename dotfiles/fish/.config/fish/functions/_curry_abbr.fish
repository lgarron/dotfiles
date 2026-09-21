function _curry_abbr
    set -l abbreviation $argv[3]
    set -l CURRIED_FN (_curry $argv)
    abbr -a "$CURRIED_FN"_abbr --regex $abbreviation --position anywhere --function "$CURRIED_FN"
end
