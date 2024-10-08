# Classic + VCS, hopefully
# TODO: Keep this in sync with `fish`, or configure semantically instead of hardcoding a snapshot.
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

    set TIME_PREFIX ""
    if [ $CMD_DURATION -ne 0 ]
        set_color purple
        set TIME_PREFIX $prompt_status "⏱️ " (math $CMD_DURATION / 1000)s
    end

    set EXPERIMENTAL_PREFIX ""
    if string match -e "$EXPERIMENTAL_FISH_LAUNCHED" "true" > /dev/null
        set EXPERIMENTAL_PREFIX "🐟🧪 "
    end
    set PREFIX $TIME_PREFIX $normal "
📂" (set_color $color_cwd) (pwd) "
"

    echo -n -s $PREFIX $normal $EXPERIMENTAL_PREFIX (set_color $fish_color_user) "$USER" $normal @ (set_color $color_host) (prompt_hostname) $normal (fish_vcs_prompt) $normal $suffix " "
end
