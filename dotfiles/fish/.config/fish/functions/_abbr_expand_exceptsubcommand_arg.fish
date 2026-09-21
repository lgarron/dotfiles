function _abbr_expand_exceptsubcommand_arg
    set -l cmd (commandline -op)
    if [ (count $cmd) -lt 3 ]
        return 1
    end

    set -l main_command $argv[1]
    # set -l arg_abbreviation $argv[2] # unused
    set -l arg_expansion $argv[3]
    set -l excluded_sub_commands $argv[4..-1]

    if string match --quiet --entire -- "$cmd[1]" "$main_command"
        if test (count $cmd) -gt 2
            if not contains -- "$cmd[2]" $excluded_sub_commands
                echo $arg_expansion
                return 0
            end
        end
    end
    return 1
end
