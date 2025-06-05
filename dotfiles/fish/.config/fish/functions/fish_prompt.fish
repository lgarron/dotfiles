# Classic + VCS, hopefully
# TODO: Keep this in sync with `fish`, or configure semantically instead of hardcoding a snapshot.

set -g __fish_git_prompt_show_informative_status 1

# TODO: these should be local, but VS Code's `fish` integration makes some bad
# assumptions that break scope for variables declared here and used in
# `fish_prompt` below.
if not set -q _FISH_PROMPT_LCARS_BOTTOM_COLOR
    set -g _FISH_PROMPT_LCARS_BOTTOM_COLOR F19E4C
end
if not set -q _FISH_PROMPT_LCARS_TOP_COLOR
    set -g _FISH_PROMPT_LCARS_TOP_COLOR B594E2
end
set -g _FISH_PROMPT_FIRST_COMMAND_HAS_RUN false # var

set -g _FISH_PROMPT_COMPACT_MODE_MAX_ROWS 15
set -g _FISH_PROMPT_EVEN_MORE_COMPACT_MODE_MAX_ROWS 10

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
    echo -e "\r"
end

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -l last_status $status
    set -l normal (set_color normal)

    # TODO: can we avoid overwring globals here while still taking updated colors into account?
    set -g ___fish_git_prompt_color_branch (set_color --reverse $_FISH_PROMPT_LCARS_BOTTOM_COLOR)" "
    set -g ___fish_git_prompt_color_branch_done " "(set_color normal; set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR)
    set -g ___fish_git_prompt_char_stateseparator " | "

    set -l fish_color_user $_FISH_PROMPT_LCARS_BOTTOM_COLOR
    set -l fish_color_host $_FISH_PROMPT_LCARS_BOTTOM_COLOR
    set -l fish_color_host_remote --bold white

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end

    # Write pipestatus
    set -l PREVIOUS_COMMAND_TIME "⏱️ "(math $CMD_DURATION / 1000)s

    # LCARS
    if string match --quiet --entire -- "$_FISH_PROMPT_FIRST_COMMAND_HAS_RUN" true
        set_color $_FISH_PROMPT_LCARS_TOP_COLOR
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo "┬"
        end
        # echo (set_color $_FISH_PROMPT_LCARS_TOP_COLOR)"│"
        set -l prompt_status (__fish_print_pipestatus "[" "] " "|" (set_color $_FISH_PROMPT_LCARS_TOP_COLOR) (set_color --bold red) $last_pipestatus)
        if not string match -e -- "$prompt_status" " " >/dev/null
            echo "├─ ❌ $prompt_status"(set_color $_FISH_PROMPT_LCARS_TOP_COLOR)"command status"
        end
        if [ (tput lines) -gt $_FISH_PROMPT_EVEN_MORE_COMPACT_MODE_MAX_ROWS ]
            _fish_prompt_echo_padded \
                "╰─── $PREVIOUS_COMMAND_TIME " \
                (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR)
        end
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end

    set -l PREFIX_BEFORE_PWD (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR)"╭─── "
    if string match --quiet --entire "$EXPERIMENTAL_FISH_LAUNCHED" true
        set -l PREFIX_BEFORE_PWD "🐠🧪 "
    end
    set -l PREFIX "$PREFIX_BEFORE_PWD"(pwd)" "
    if test (string length --visible $PREFIX) -gt $COLUMNS
        set PREFIX $PREFIX_BEFORE_PWD(prompt_pwd)" "
    end
    _fish_prompt_echo_padded \
        $PREFIX \
        (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR)

    set FISH_JJ_PROMPT (fish_jj_prompt "%s")
    if not string match -e "$FISH_JJ_PROMPT" "" >/dev/null
        set -l PREFIX (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR)"├─ (jj) "(set_color normal)$FISH_JJ_PROMPT" "
        echo -n $PREFIX
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end

    set FISH_GIT_PROMPT (fish_git_prompt "%s")
    if not string match -e "$FISH_GIT_PROMPT" "" >/dev/null
        set -l PREFIX (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR)"├─ (git) "(set_color normal)$FISH_GIT_PROMPT" "
        echo -n $PREFIX
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end

    set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR
    if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
        echo -n "├─ "
        set suffix "
" (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR) "│"
    else
        echo -n "│ "
        set suffix " │" (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR) ""
    end

    echo -n -s (set_color $fish_color_user) "$USER" @ (set_color $color_host) (prompt_hostname) (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR) $suffix " " (set_color normal)
end

# TODO: remove this `@fish-lsp-disable` after false positives are reduced (https://github.com/ndonfris/fish-lsp/issues/80).
# @fish-lsp-disable-next-line 4004
function _fish_prompt_preexec_blank_line --on-event fish_preexec
    if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
        echo (set_color $_FISH_PROMPT_LCARS_BOTTOM_COLOR)"┴"(set_color normal)
    end
    set _FISH_PROMPT_FIRST_COMMAND_HAS_RUN true
end
