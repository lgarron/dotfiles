function gx
    open -a GitX . &
    disown
    $DOTFILES_FOLDER/scripts/system/dell-display-position-app-on-bottom.ts GitX
end
