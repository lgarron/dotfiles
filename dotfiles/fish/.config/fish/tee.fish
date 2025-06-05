# abbr -a t "tee >(pbcopy)"
function 📋
    # TODO: pipe?
    set -l TEMP_FILE (mktemp -t "pbcopy")
    cat > $TEMP_FILE
    cat $TEMP_FILE
    cat $TEMP_FILE | pbcopy
    rm $TEMP_FILE
end
abbr -a t "📋"

function tt
    if set --query _FISH_SHELL_PASTEBOARD_FILE
    rm -f $_FISH_SHELL_PASTEBOARD_FILE &
    end
    set -gx _FISH_SHELL_PASTEBOARD_FILE (mktemp -t "pasteboard")
    cat > $_FISH_SHELL_PASTEBOARD_FILE
    cat $_FISH_SHELL_PASTEBOARD_FILE
end
function tt_paste
    set -l cmd (commandline -op)
    if [ (count $cmd) -lt 2 ]
    return 1
    end
    cat $_FISH_SHELL_PASTEBOARD_FILE
end
abbr -a tt --position anywhere --function tt_paste
