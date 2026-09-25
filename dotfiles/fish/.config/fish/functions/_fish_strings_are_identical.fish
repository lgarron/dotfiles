function _fish_strings_are_identical
    string match --quiet --entire -- $argv[1] $argv[2]
end
