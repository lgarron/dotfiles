function hevc-HEAD
    set COMMAND $DOTFILES_FOLDER/scripts/video/hevc.ts $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end
