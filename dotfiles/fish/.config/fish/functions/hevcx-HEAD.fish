function hevcx-HEAD
    set COMMAND $DOTFILES_FOLDER/scripts/video/hevcx-HEAD $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end

# False positive
# @fish-lsp-disable-next-line 1004
hevcx-HEAD --completions fish | source >/dev/null
