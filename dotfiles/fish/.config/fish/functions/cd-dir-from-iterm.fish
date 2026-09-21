function cd-dir-from-iterm
    set -l NUM_DASHES (math $COLUMNS - 1)
    echo -n (set_color B594E2)"╭"
    string repeat -n $NUM_DASHES "─"
    echo "┴ Launching shell in folder for path:"
    echo ""
    echo (set_color --bold)"$argv[1]"(set_color B594E2)
    echo ""
    if string match --quiet --entire -- "$TERM_PROGRAM" "iTerm.app" >/dev/null
        set SHORTCUT "⇧⌘↩"
    else
        set SHORTCUT "^⌥R"
    end
    echo "┬ Use $SHORTCUT to place this into a command."
    echo -n "╰"
    string repeat -n $NUM_DASHES "─"
    echo -n (set_color normal)

    cd-dir $argv[1]
end
