# This takes exactly two arguments, and no options. `--` is treated as an argument if it is passed.
function _fish_strings_are_identical
    set -l COUNT (count $argv)
    if test "$COUNT" -ne 2
        echo "Incorrect argument count ($COUNT) for `_fish_strings_are_identical`! $argv" >&2
        return 2
    end
    # This makes me paranoid, but everything else I know is either unsafer or
    # requires shelling out to a program.
    test "$argv[1]" = "$argv[2]"
end
