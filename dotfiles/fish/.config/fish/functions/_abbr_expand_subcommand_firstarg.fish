function _abbr_expand_subcommand_firstarg
    set -l cmd (commandline -op)
    if [ (count $cmd) -lt 3 ]
        return 1
    end

    set -l main_command $argv[1]
    set -l arg_abbreviation $argv[2]
    set -l arg_expansion $argv[3]
    set -l sub_commands $argv[4..-1]

    if _fish_strings_are_identical "$cmd[1]" "$main_command"
        if test (count $cmd) = 3
            if _fish_strings_are_identical "$cmd[3]" "$arg_abbreviation"
                if contains -- "$cmd[2]" $sub_commands
                    echo $arg_expansion
                    return 0
                end
            end
        end
    end
    return 1
end
