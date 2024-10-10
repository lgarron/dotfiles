# Classic + VCS, hopefully
# TODO: Keep this in sync with `fish`, or configure semantically instead of hardcoding a snapshot.

set __fish_git_prompt_show_informative_status 1

# TODO: these should be local, but VS Code's `fish` integration makes some bad
# assumptions that break scope for variables declared here and used in
# `fish_prompt` below.
set -g _FISH_LCARS_ORANGE F19E4C
set -g _FISH_LCARS_LAVENDER B594E2
set -g _FISH_PROMPT_FIRST_COMMAND_HAS_RUN false # var

set -g ___fish_git_prompt_color_branch (set_color --reverse $_FISH_LCARS_ORANGE)" "
set -g ___fish_git_prompt_color_branch_done " "(set_color normal; set_color $_FISH_LCARS_ORANGE)
set -g ___fish_git_prompt_char_stateseparator " | "

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

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -l last_status $status
    set -l normal (set_color normal)

    set -l fish_color_user $_FISH_LCARS_ORANGE
    set -l fish_color_host $_FISH_LCARS_ORANGE
    set -l fish_color_host_remote white

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end

    # Write pipestatus
    set -l PREVIOUS_COMMAND_TIME "⏱️ "(math $CMD_DURATION / 1000)s

    # LCARS
    if string match -e -- "$_FISH_PROMPT_FIRST_COMMAND_HAS_RUN" true > /dev/null
        set_color $_FISH_LCARS_LAVENDER
        # echo (set_color $_FISH_LCARS_LAVENDER)"│"
        set -l prompt_status (__fish_print_pipestatus "[" "] " "|" (set_color $_FISH_LCARS_LAVENDER) (set_color --bold red) $last_pipestatus)
        if not string match -e -- "$prompt_status" " " > /dev/null
            echo "├─ ❌ $prompt_status"(set_color $_FISH_LCARS_LAVENDER)"command status"
        end
        _echo_padded \
            "╰─── $PREVIOUS_COMMAND_TIME " \
            (set_color $_FISH_LCARS_ORANGE)
        echo ""
    end

    set -l PREFIX_BEFORE_PWD (set_color $_FISH_LCARS_ORANGE)"╭─── "
    if string match -e "$EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null
        set -l PREFIX_BEFORE_PWD "🐠🧪 "
    end
    set -l PREFIX "$PREFIX_BEFORE_PWD"(pwd)" "
    if test (string length --visible $PREFIX) -gt $COLUMNS
        set PREFIX $PREFIX_BEFORE_PWD(prompt_pwd)" "
    end
    _echo_padded \
        $PREFIX \
        (set_color $_FISH_LCARS_ORANGE)

    set FISH_VCS_PROMPT (fish_vcs_prompt "%s")
    if not string match -e "$FISH_VCS_PROMPT" "" > /dev/null
        set -l PREFIX (set_color $_FISH_LCARS_ORANGE)"├─ "$FISH_VCS_PROMPT" "
        echo $PREFIX
    end
    echo -n "├─ "
    set suffix "
" (set_color $_FISH_LCARS_ORANGE) "│"

    echo -n -s (set_color $fish_color_user) "$USER" @ (set_color $color_host) (prompt_hostname) (set_color $_FISH_LCARS_ORANGE) $suffix " "
end

function _fish_prompt_preexec_blank_line --on-event fish_preexec
    echo (set_color $_FISH_LCARS_ORANGE)"┴"(set_color normal)
    set _FISH_PROMPT_FIRST_COMMAND_HAS_RUN true
end

# This needs to be here to avoid an extra blank line in the prompt.
function _fish_prompt_postexec_blank_line --on-event fish_postexec
    echo (set_color $_FISH_LCARS_LAVENDER)"┬"(set_color normal)
end
