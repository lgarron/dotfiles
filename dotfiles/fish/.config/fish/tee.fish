# LSP override: This is an "exported" function (meant to be used outside this file).
# @fish-lsp-disable-next-line 4004
function 📋
    set DIR (mktemp -d -t pipe)

    mkfifo $DIR/PIPE $DIR/CLIPBOARD

    cat - | tee $DIR/PIPE $DIR/CLIPBOARD | cat >/dev/null &
    cat $DIR/PIPE &

    # Adapated from: https://jvns.ca/blog/2025/06/24/new-zine--the-secret-rules-of-the-terminal/#i-learned-a-surprising-amount-writing-this-zine
    printf "\033]52;c;%s\007" (cat $DIR/CLIPBOARD | base64 | tr -d '\n') &
    wait

    rm -rf $DIR
end
abbr -a t "📋"

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
# TODO: remove this `@fish-lsp-disable` after false positives are reduced (https://github.com/ndonfris/fish-lsp/issues/80).
# @fish-lsp-disable-next-line 4004
function tt_paste
    set -l cmd (commandline -op)
    if [ (count $cmd) -lt 2 ]
    return 1
    end
    cat $_FISH_SHELL_PASTEBOARD_FILE
end
abbr -a tt --position anywhere --function tt_paste
