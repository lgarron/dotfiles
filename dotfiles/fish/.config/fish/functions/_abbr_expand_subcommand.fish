function _abbr_expand_subcommand
    set -l main_command $argv[1]
    set -l sub_command_abbreviation $argv[2]
    set -l expansion $argv[3]
    set -l cmd (commandline -op)
    if string match --quiet --entire -- "$cmd[1]" "$main_command"
        if test (count $cmd) -eq 2
            if string match --quiet --entire -- "$cmd[2]" "$sub_command_abbreviation"
                echo $expansion
                return 0
            end
        end
    end
    return 1
end
