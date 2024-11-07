# Classic + VCS, hopefully
# TODO: Keep this in sync with `fish`, or configure semantically instead of hardcoding a snapshot.

set -g __fish_git_prompt_show_informative_status 1

# TODO: these should be local, but VS Code's `fish` integration makes some bad
# assumptions that break scope for variables declared here and used in
# `fish_prompt` below.
if not set -q _FISH_LCARS_BOTTOM; set -g _FISH_LCARS_BOTTOM F19E4C; end
if not set -q _FISH_LCARS_TOP; set -g _FISH_LCARS_TOP B594E2; end
set -g _FISH_PROMPT_FIRST_COMMAND_HAS_RUN false # var

set -g _FISH_PROMPT_COMPACT_MODE_MAX_ROWS 15
set -g _FISH_PROMPT_EVEN_MORE_COMPACT_MODE_MAX_ROWS 12

function _fish_prompt_is_fish_HEAD_build
    echo $version | grep "3\.[0-9]\+\.[0-9]\+-[0-9]\+-g[0-9a-f]\{8\}" > /dev/null
end

function _fish_prompt_echo_padded
    set -l PREFIX $argv[1]
    set -l SET_COLOR_END $argv[2]
    set -l NUM_DASHES (math $COLUMNS - (string length --visible $PREFIX))
    if test $NUM_DASHES -lt 0
        echo $PREFIX$SET_COLOR_END
        return
    end
    set -l DASHES (string repeat -n $NUM_DASHES "─")
    echo -n $PREFIX$DASHES$SET_COLOR_END
    if _fish_prompt_is_fish_HEAD_build
        echo -e "\r"
    else
        # Older `fish` has some compatibility issues around character width calculation and newlines. We fall back to a simple newline here for "close enough" functionality.
        echo ""
    end
end

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -l last_status $status
    set -l normal (set_color normal)

    # TODO: can we avoid overwring globals here while still taking updated colors into account?
    set -g ___fish_git_prompt_color_branch (set_color --reverse $_FISH_LCARS_BOTTOM)" "
    set -g ___fish_git_prompt_color_branch_done " "(set_color normal; set_color $_FISH_LCARS_BOTTOM)
    set -g ___fish_git_prompt_char_stateseparator " | "

    set -l fish_color_user $_FISH_LCARS_BOTTOM
    set -l fish_color_host $_FISH_LCARS_BOTTOM
    set -l fish_color_host_remote --bold white

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end

    # Write pipestatus
    set -l PREVIOUS_COMMAND_TIME "⏱️ "(math $CMD_DURATION / 1000)s

    # LCARS
    if string match -e -- "$_FISH_PROMPT_FIRST_COMMAND_HAS_RUN" true > /dev/null
        set_color $_FISH_LCARS_TOP
        # echo (set_color $_FISH_LCARS_TOP)"│"
        set -l prompt_status (__fish_print_pipestatus "[" "] " "|" (set_color $_FISH_LCARS_TOP) (set_color --bold red) $last_pipestatus)
        if not string match -e -- "$prompt_status" " " > /dev/null
            echo "├─ ❌ $prompt_status"(set_color $_FISH_LCARS_TOP)"command status"
        end
        if [ (tput lines) -gt $_FISH_PROMPT_EVEN_MORE_COMPACT_MODE_MAX_ROWS ]
            _fish_prompt_echo_padded \
                "╰─── $PREVIOUS_COMMAND_TIME " \
                (set_color $_FISH_LCARS_BOTTOM)
        end
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end

    set -l PREFIX_BEFORE_PWD (set_color $_FISH_LCARS_BOTTOM)"╭─── "
    if string match -e "$EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null
        set -l PREFIX_BEFORE_PWD "🐠🧪 "
    end
    set -l PREFIX "$PREFIX_BEFORE_PWD"(pwd)" "
    if test (string length --visible $PREFIX) -gt $COLUMNS
        set PREFIX $PREFIX_BEFORE_PWD(prompt_pwd)" "
    end
    _fish_prompt_echo_padded \
        $PREFIX \
        (set_color $_FISH_LCARS_BOTTOM)

    set FISH_VCS_PROMPT (fish_vcs_prompt "%s")
    if not string match -e "$FISH_VCS_PROMPT" "" > /dev/null
        set -l PREFIX (set_color $_FISH_LCARS_BOTTOM)"├─ "$FISH_VCS_PROMPT" "
        echo -n $PREFIX
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end
    if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
        echo -n "├─ "
    set suffix "
" (set_color $_FISH_LCARS_BOTTOM) "│"
    else
        echo -n "│ "
        set suffix " │" (set_color $_FISH_LCARS_BOTTOM) ""
    end

    echo -n -s (set_color $fish_color_user) "$USER" @ (set_color $color_host) (prompt_hostname) (set_color $_FISH_LCARS_BOTTOM) $suffix " " (set_color normal)
end

function _fish_prompt_preexec_blank_line --on-event fish_preexec
    echo (set_color $_FISH_LCARS_BOTTOM)"┴"(set_color normal)
    set _FISH_PROMPT_FIRST_COMMAND_HAS_RUN true
end

# This needs to be here to avoid an extra blank line in the prompt.
function _fish_prompt_postexec_blank_line --on-event fish_postexec
    if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
        echo (set_color $_FISH_LCARS_TOP)"┬"(set_color normal)
    end
end
