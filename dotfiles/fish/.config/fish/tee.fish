abbr -a t --position command "📋"

# LSP override: This is an "exported" function (meant to be used outside this file).
# @fish-lsp-disable-next-line 4004
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
    echo -n '"'
    cat $_FISH_SHELL_PASTEBOARD_FILE | string escape --style script
    echo -n '"'
end
abbr -a tt --position anywhere --function tt_paste
