# Classic + VCS, hopefully
# TODO: Keep this in sync with `fish`, or configure semantically instead of hardcoding a snapshot.
set -l THEMES "html" "LCARS"
set _FISH_PROMPT_THEME $THEMES[(random 1 2)]

set __fish_git_prompt_show_informative_status 1

function _echo_padded
    set -l PREFIX $argv[1]
    set -l SET_COLOR_END $argv[2]
    set -l NUM_DASHES (math $COLUMNS - (string length --visible $PREFIX))
    if test $NUM_DASHES -lt 0
        echo $PREFIX$SET_COLOR_END
        return
    end
    set -l DASHES (string repeat -n $NUM_DASHES "─")
    echo -n $PREFIX$DASHES$SET_COLOR_END
    echo -e "\r"
end

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
    set -l PREVIOUS_COMMAND_TIME "⏱️ "(math $CMD_DURATION / 1000)s

    set -l _VCS ""
    if string match -e -- $_FISH_PROMPT_THEME "html" > /dev/null
        set -l prompt_status (__fish_print_pipestatus "[" "] " "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

        # html
        if string match -e -- "$_FISH_PROMPT_AFTER_FIRST_RUN" true > /dev/null
            echo -n (set_color blue)"</command>"(set_color purple)" <!-- $prompt_status"(set_color purple)$PREVIOUS_COMMAND_TIME" -->"
        end
        
        echo (set_color blue)
        echo -n "<command "
        if string match -e "$EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null
            echo -n "experimental=\"🧪\" "
        end
        echo "path=\""(set_color $color_cwd)(pwd)(set_color blue)"\">"
        set _VCS (fish_vcs_prompt)
    else
        # LCARS
        if string match -e -- "$_FISH_PROMPT_AFTER_FIRST_RUN" true > /dev/null
            set_color B594E2
            # echo (set_color B594E2)"│"
            set -l prompt_status (__fish_print_pipestatus "[" "] " "|" (set_color B594E2) (set_color --bold B594E2) $last_pipestatus)
            if not string match -e -- "$prompt_status" " " > /dev/null
                echo "├─ $prompt_status"(set_color B594E2)"command status"
            end
            _echo_padded \
                "╰─── $PREVIOUS_COMMAND_TIME " \
                (set_color F19E4C)
            # echo ""
        end

        set -l PREFIX (set_color F19E4C)"╭─── "
        if string match -e "$EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null
            set -l PREFIX "🐠🧪 "
        end
        set -l PREFIX $PREFIX(pwd)" "
        _echo_padded \
            $PREFIX \
            (set_color F19E4C)

        set FISH_VCS_PROMPT (fish_vcs_prompt)
        if not string match -e "$FISH_VCS_PROMPT" "" > /dev/null
            set -l PREFIX (set_color F19E4C)"├─"$FISH_VCS_PROMPT" "
            echo $PREFIX
        end
        echo -n "├─ "
        set suffix $suffix"
" (set_color F19E4C) "│"
    end

    set _FISH_PROMPT_AFTER_FIRST_RUN true

    echo -n -s (set_color $fish_color_user) "$USER" $normal @ (set_color $color_host) (prompt_hostname) $normal $_VCS $normal $suffix " "
end
