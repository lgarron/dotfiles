function gx
    open -a GitX . &
    disown
    $DOTFILES_FOLDER/scripts/display/dell-display-position-app-on-bottom.ts GitX
end
