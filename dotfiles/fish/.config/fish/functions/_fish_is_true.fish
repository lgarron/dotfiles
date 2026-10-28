# This takes exactly one argument, and no options. `--` is treated as an argument if it is passed.
function _fish_is_true
    _fish_strings_are_identical "$argv[1]" true
end
