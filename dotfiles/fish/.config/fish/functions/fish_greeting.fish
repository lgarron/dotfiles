# Machines

# MOTD

function _fish_greeting_echo
    for arg in $argv
        string shorten --max $COLUMNS $arg
    end
end

# If `hostname -s` is incorrect on macOS:
#
# 1. `dscacheutil -flushcache`
# 2. Reboot
#
# Alternatively, use:
#
#     set MAC_HOSTNAME (which scutil > /dev/null && scutil --get ComputerName)
#
# https://apple.stackexchange.com/a/53042
#
# To fix a hostname (e.g. if it was changed due to conflict from multiple paths on the same network):
#
#     set FIXED_HOSTNAME Germain
#     sudo scutil --set HostName $FIXED_HOSTNAME
#     sudo scutil --set ComputerName $FIXED_HOSTNAME
#     sudo scutil --set LocalHostName $FIXED_HOSTNAME
#
# Font: https://www.npmjs.com/package/stalwart-ascii-font?activeTab=readme
function fish_greeting

    # TODO: why can't we cache these outside the function?
    set -l GERMAIN Germain germain Germain.local
    set -l PYTHAGORAS Pythagoras pythagoras Pythagoras.local Pythagoras.lan
    set -l HIPPASUS Hippasus hippasus Hippasus.local Hippasus.lan

    set -l _CURRENT_HOSTNAME (hostname -s)

    if contains $_CURRENT_HOSTNAME $GERMAIN
        set_color B594E2
        echo -n -e "\r" # Clear any pending typed text (it will still be passed to the next prompt).
        _fish_greeting_echo \
            "╭──                                          ──╮" \
            "│ ╭────╮╭────╮╭────╮╭─╮  ╭─╮╭────╮╭───╮╭──╮╭─╮ │" \
            "│ │ ╭──┤│ ──┬╯│ ⊂⊃ ││  \/  ││ ⊂⊃ │╰╮ ╭╯│  ╰╮ │ │" \
            "│ │ ╰╯ ││ ──┴╮│ \ \╯│ │\/│ ││ ╭╮ │╭╯ ╰╮│ ╰╮  │ │" \
            "│ ╰────╯╰────╯╰─╯╰─╯╰─╯  ╰─╯╰─╯╰─╯╰───╯╰─╯╰──╯ │" \
            "╰──                                          ──╯"
    else if contains $_CURRENT_HOSTNAME $PYTHAGORAS
        set -g _FISH_PROMPT_LCARS_HEADER_COLOR 44CCAA
        set -g _FISH_PROMPT_LCARS_TRAILER_COLOR 66AAFF
        set_color 66AAFF
        echo -n -e "\r" # Clear any pending typed text (it will still be passed to the next prompt).
        _fish_greeting_echo \
            "╭──                                                              ──╮" \
            "│  ╭────╮╭─╮ ╭─╮╭─────╮╭─╮╭─╮╭────╮╭────╮╭────╮╭────╮╭────╮╭────╮  │" \
            "│  │ ⊂⊃ ││ ╰─╯ │╰─╮ ╭─╯│ ╰╯ ││ ⊂⊃ ││ ╭──┤│ ╭╮ ││ ⊂⊃ ││ ⊂⊃ ││  ──┤  │" \
            "│  │ ╭──╯╰─╮ ╭─╯  │ │  │ ╭╮ ││ ╭╮ ││ ╰╯ ││ ╰╯ ││ \ \╯│ ╭╮ │├──  │  │" \
            "│  ╰─╯     ╰─╯    ╰─╯  ╰─╯╰─╯╰─╯╰─╯╰────╯╰────╯╰─╯╰─╯╰─╯╰─╯╰────╯  │" \
            "╰──                                                              ──╯"
    else if contains $_CURRENT_HOSTNAME $HIPPASUS
        set -g _FISH_PROMPT_LCARS_HEADER_COLOR FFAAFF
        set -g _FISH_PROMPT_LCARS_TRAILER_COLOR FF8888
        set_color FF8888
        echo -n -e "\r" # Clear any pending typed text (it will still be passed to the next prompt).
        _fish_greeting_echo \
            "╭──                                                ──╮" \
            "│  ╭─╮╭─╮╭───╮╭────╮╭────╮╭────╮╭────╮╭─╮ ╭─╮╭────╮  │" \
            "│  │ ╰╯ │╰╮ ╭╯│ ⊂⊃ ││ ⊂⊃ ││ ⊂⊃ ││  ──┤│ │ │ ││  ──┤  │" \
            "│  │ ╭╮ │╭╯ ╰╮│ ╭──╯│ ╭──╯│ ╭╮ │├──  ││ ╰─╯ │├──  │  │" \
            "│  ╰─╯╰─╯╰───╯╰─╯   ╰─╯   ╰─╯╰─╯╰────╯╰─────╯╰────╯  │" \
            "╰──                                                ──╯"
    else if contains "dreamhost.com" (hostname -d)
        set -g _FISH_PROMPT_LCARS_HEADER_COLOR FFDD88
        set -g _FISH_PROMPT_LCARS_TRAILER_COLOR FFDD88
        set_color FFDD88
        echo -n -e "\r" # Clear any pending typed text (it will still be passed to the next prompt).
        _fish_greeting_echo \
            "╭───╮ ╭────╮╭────╮╭────╮╭─╮  ╭─╮╭─╮╭─╮╭────╮╭────╮╭─────╮" \
            "│ ╭╮ ││ ⊂⊃ ││ ──┬╯│ ⊂⊃ ││  \/  ││ ╰╯ ││ ╭╮ ││  ──┤╰─╮ ╭─╯" \
            "│ ╰╯ ││ \ \╯│ ──┴╮│ ╭╮ ││ │\/│ ││ ╭╮ ││ ╰╯ │├──  │  │ │  " \
            "╰───╯ ╰─╯╰─╯╰────╯╰─╯╰─╯╰─╯  ╰─╯╰─╯╰─╯╰────╯╰────╯  ╰─╯  "
    else
        set -g _FISH_PROMPT_LCARS_HEADER_COLOR D0B699
        set -g _FISH_PROMPT_LCARS_TRAILER_COLOR D0B699
        echo -n "🐟 Welcome to "
        set_color --bold
        echo (hostname -s)
    end
end
