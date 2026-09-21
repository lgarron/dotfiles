function tt_paste
    set -l cmd (commandline -op)
    if [ (count $cmd) -lt 2 ]
        return 1
    end
    echo -n '"'
    cat $_FISH_SHELL_PASTEBOARD_FILE | string escape --style script
    echo -n '"'
end
