# Classic + VCS, hopefully
# TODO: Keep this in sync with `fish`, or configure semantically instead of hardcoding a snapshot.
set -l THEMES "html" "LCARS"
set _FISH_PROMPT_THEME $THEMES[(random 1 2)]

set _FISH_PROMPT_AFTER_FIRST_RUN false
function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -l last_status $status
    set -l normal (set_color normal)

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l prefix
    set -l suffix '>'
    if contains -- $USER root toor
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end

    # Write pipestatus
    set -l prompt_status (__fish_print_pipestatus "[" "] " "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

    set PREVIOUS_COMMAND_SUMMARY ""
    # if [ $CMD_DURATION -ne 0 ]
        set PREVIOUS_COMMAND_SUMMARY "⏱️ "(math $CMD_DURATION / 1000)s
        if not string match -e -- $prompt_status "" > /dev/null
            set PREVIOUS_COMMAND_SUMMARY "$prompt_status"(set_color purple)"$PREVIOUS_COMMAND_SUMMARY"
        end
    # end

    set MAIN_PROMPT_PWD ""
    if string match -e -- $_FISH_PROMPT_THEME "html" > /dev/null
        if string match -e -- "$_FISH_PROMPT_AFTER_FIRST_RUN" true > /dev/null
            echo (set_color blue)"</command>"(set_color purple)" <!--" $PREVIOUS_COMMAND_SUMMARY "-->"
        end
        
        echo -n $normal
        echo -n -e "\r"(set_color blue)
        echo -n "<command"
        if string match -e "$EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null
            echo -n " experimental=\"🧪\" "
        end
        echo -n "path=\""
        echo (set_color $color_cwd)(pwd)(set_color blue)"\">"
    else
        # LCARS
        set PREVIOUS_COMMAND_SUMMARY_LENGTH (string length --visible $PREVIOUS_COMMAND_SUMMARY)
        set DASHES (string repeat -n (math $COLUMNS - $PREVIOUS_COMMAND_SUMMARY_LENGTH - 6) "─")
        if string match -e -- "$_FISH_PROMPT_AFTER_FIRST_RUN" true > /dev/null
            echo -n (set_color purple)"╰─── "$PREVIOUS_COMMAND_SUMMARY" "$DASHES(set_color green)
            echo -e "\r"
        end
        echo -n (set_color green)

        if string match -e "$EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null
            set EXPERIMENTAL_INFIX " 🐠🧪 "
        end
        set EXPERIMENTAL_INFIX $EXPERIMENTAL_INFIX""(pwd)" "
        set EXPERIMENTAL_INFIX_LENGTH (string length --visible $EXPERIMENTAL_INFIX)
        echo -n "╭─"$EXPERIMENTAL_INFIX
        set NUM_DASHES (math $COLUMNS - $EXPERIMENTAL_INFIX_LENGTH - 2)
        if test $NUM_DASHES -gt 0
            set DASHES (string repeat -n $NUM_DASHES "─")
            echo -n $DASHES
            echo -e "\r"
        else
            echo ""
        end
    end

    set _FISH_PROMPT_AFTER_FIRST_RUN true

    echo -n -s $normal (set_color $fish_color_user) "$USER" $normal @ (set_color $color_host) (prompt_hostname) $normal (fish_vcs_prompt) $normal $suffix " "
end
