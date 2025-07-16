# LCARS (Ster Trek) inspired `fish` prompt.

set -g __fish_git_prompt_show_informative_status 1

# TODO: these should be local, but VS Code's `fish` integration makes some bad
# assumptions that break scope for variables declared here and used in
# `fish_prompt` below.
if not set -q _FISH_PROMPT_LCARS_HEADER_COLOR
    set -g _FISH_PROMPT_LCARS_HEADER_COLOR F19E4C
end
if not set -q _FISH_PROMPT_LCARS_TRAILER_COLOR
    set -g _FISH_PROMPT_LCARS_TRAILER_COLOR B594E2
end
set -g _FISH_PROMPT_FIRST_COMMAND_HAS_RUN false # var

set -g _FISH_PROMPT_COMPACT_MODE_MAX_ROWS 15

function _fish_prompt_echo_padded
    set -l PREFIX $argv[1]
    set -l SET_COLOR_END $argv[2]
    set -l PADDING_CHARACTER $argv[3]
    set -l NUM_PADDING_CHARACTERS (math $COLUMNS - (string length --visible $PREFIX))
    if test $NUM_PADDING_CHARACTERS -lt 0
        echo $PREFIX$SET_COLOR_END
        return
    end
    set -l DASHES (string repeat -n $NUM_PADDING_CHARACTERS $PADDING_CHARACTER)
    echo -n $PREFIX$DASHES$SET_COLOR_END
    echo -e "\r"
end

function fish_prompt --description 'Write out the prompt'
    set -l normal (set_color normal)

    # TODO: can we avoid overwring globals here while still taking updated colors into account?
    set -g ___fish_git_prompt_color_branch (set_color --reverse $_FISH_PROMPT_LCARS_HEADER_COLOR)" "
    set -g ___fish_git_prompt_color_branch_done " "(set_color normal; set_color $_FISH_PROMPT_LCARS_HEADER_COLOR)
    set -g ___fish_git_prompt_char_stateseparator " | "

    set -l fish_color_user $_FISH_PROMPT_LCARS_HEADER_COLOR
    set -l fish_color_host $_FISH_PROMPT_LCARS_HEADER_COLOR
    set -l fish_color_host_remote --bold white

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end

    set -l PREFIX_BEFORE_PWD (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR)"╭─── "
    if string match --quiet --entire "$EXPERIMENTAL_FISH_LAUNCHED" true
        set -l PREFIX_BEFORE_PWD "🐠🧪 "
    end
    set -l PREFIX "$PREFIX_BEFORE_PWD"(pwd)" "
    if test (string length --visible $PREFIX) -gt $COLUMNS
        set PREFIX $PREFIX_BEFORE_PWD(prompt_pwd)" "
    end
    _fish_prompt_echo_padded \
        $PREFIX \
        (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR) \
        "─"

    set FISH_JJ_PROMPT (fish_jj_prompt "%s")
    if not string match -e "$FISH_JJ_PROMPT" "" >/dev/null
        set -l PREFIX (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR)"├─ (jj) "(set_color normal)$FISH_JJ_PROMPT" "
        echo -n $PREFIX
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end

    set FISH_GIT_PROMPT (fish_git_prompt "%s")
    if not string match -e "$FISH_GIT_PROMPT" "" >/dev/null
        set -l PREFIX (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR)"├─ (git) "(set_color normal)$FISH_GIT_PROMPT" "
        echo -n $PREFIX
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end

    set_color $_FISH_PROMPT_LCARS_HEADER_COLOR
    if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
        echo -n "├─ "
        set suffix "
" (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR) "│"
    else
        echo -n "│ "
        set suffix " │" (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR) ""
    end

    echo -n -s (set_color $fish_color_user) "$USER" @ (set_color $color_host) (prompt_hostname) (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR) $suffix " " (set_color normal)
end

# TODO: remove this `@fish-lsp-disable` after false positives are reduced (https://github.com/ndonfris/fish-lsp/issues/80).
# @fish-lsp-disable-next-line 
function _fish_prompt_preexec_blank_line --on-event fish_preexec
    if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
        echo (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR)"┴"(set_color normal)
    end
    set -g _FISH_PROMPT_FIRST_COMMAND_HAS_RUN true
end

# TODO: remove this `@fish-lsp-disable` after false positives are reduced (https://github.com/ndonfris/fish-lsp/issues/80).
# @fish-lsp-disable-next-line 4004 4007
function _fish_prompt_postexec_lcars --on-event fish_postexec
    set -l statuses $status $pipestatus
    set -l saved_status $statuses[1]
    set -l saved_pipestatus $statuses[2]

    set -l PREVIOUS_COMMAND_TIME "⏱️ "(math $CMD_DURATION / 1000)s

    # Indicator for the lack of a trailing newline.
    # See: https://www.vidarholen.net/contents/blog/?p=878
    echo -n "⏎"(string repeat -n (math $COLUMNS-1) " ")
    echo -ne "\r"

    if string match --quiet --entire -- "$_FISH_PROMPT_FIRST_COMMAND_HAS_RUN" true
        set_color $_FISH_PROMPT_LCARS_TRAILER_COLOR
        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo "┬"
        end

        ######## Trailer sequence calculations ########

        set -l final_trailer_is_time true

        set -l prompt_status (__fish_print_pipestatus "[" "] " " | " (set_color $_FISH_PROMPT_LCARS_TRAILER_COLOR) (set_color --bold red) $saved_pipestatus)
        if not string match --quiet --entire -- "$prompt_status" " "
            set final_trailer_is_time false
        end

        # Interacts with the `jj` wrapper functionn.
        if _fish_is_true $final_trailer_is_time && functions -qv _fish_postexec_refresh_gg_calculate_if_needed
            if _fish_is_true (_fish_postexec_refresh_gg_calculate_if_needed)
                set final_trailer_is_time false
            end
        end

        ######## Print trailers ########

        if _fish_is_true $final_trailer_is_time
            _fish_prompt_echo_padded \
                "╰─── $PREVIOUS_COMMAND_TIME " \
                (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR) \
                "─"
        else
            echo "├─ $PREVIOUS_COMMAND_TIME "
        end

        if not string match --quiet --entire -- "$prompt_status" " "
            echo "├─ ❌ $prompt_status"(set_color $_FISH_PROMPT_LCARS_TRAILER_COLOR)"command status"
        end

        if functions -qv _fish_postexec_refresh_gg_if_needed
            _fish_postexec_refresh_gg_if_needed --fancy
        end

        if not _fish_is_true $final_trailer_is_time
            _fish_prompt_echo_padded \
                "╰───" \
                (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR) \
                "─"
        end

        if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
            echo ""
        end
    end

    # Interacts with the `jj` wrapper functionn.
    if functions -qv _fish_postexec_refresh_gg_reset
        _fish_postexec_refresh_gg_reset
    end

    # Try to tell VS Code that *here* is actually the end of the command.
    # For some reason, this does not work.
    # See: https://github.com/fish-shell/fish-shell/issues/11634
    if functions -q __vsc_esc
        __vsc_esc D $saved_status
    end
    functions -e __vsc_cmd_finished
end

functions -e __vsc_cmd_finished

# TODO: remove this `@fish-lsp-disable` after false positives are reduced (https://github.com/ndonfris/fish-lsp/issues/80).
# @fish-lsp-disable-next-line 4004 4007
function _fish_cancel_lcars --on-event fish_cancel
    set_color red
    echo ""
    _fish_prompt_echo_padded \
        "╰─── ⌃C (command input cleared) " \
        (set_color $_FISH_PROMPT_LCARS_HEADER_COLOR) \
        "─"
    if [ (tput lines) -gt $_FISH_PROMPT_COMPACT_MODE_MAX_ROWS ]
        echo ""
    end
end
