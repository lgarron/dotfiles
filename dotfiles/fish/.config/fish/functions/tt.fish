function tt
    if set --query _FISH_SHELL_PASTEBOARD_FILE
        rm -f $_FISH_SHELL_PASTEBOARD_FILE &
    end
    set -gx _FISH_SHELL_PASTEBOARD_FILE (mktemp -t "pasteboard")
    cat >$_FISH_SHELL_PASTEBOARD_FILE
    cat $_FISH_SHELL_PASTEBOARD_FILE
end
