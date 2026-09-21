function _abbr_expand_anyarg
    set -l main_command $argv[1] # TODO: allow this to a function invocation, to allow defining for multiple commands?
    # set -l command_abbreviation $argv[2] # unused
    set -l expansion $argv[3] # TODO: make this a lazy function invocation?
    set -l cmd (commandline -op)
    if test "$cmd[1]" = $main_command
        echo $expansion
        return 0
    end
    return 1
end
