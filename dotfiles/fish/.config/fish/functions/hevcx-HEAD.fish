function hevcx-HEAD
    set COMMAND $DOTFILES_FOLDER/scripts/video/hevcx-HEAD $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end

hevcx-HEAD --completions fish | source >/dev/null
