function hevcx-HEAD
    set COMMAND $DOTFILES_FOLDER/scripts/video/hevcx.ts $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end
