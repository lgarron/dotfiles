## jj

    abbr -a j "jj"

    function _fish_abbr_jj_subcommand
        set -l abbrevation $argv[1]
        set -l expansion $argv[2]
        abbr -a "j$abbrevation" "jj $expansion"
        abbr_subcommand jj $abbrevation $expansion
    end

    # m⎵ → main
    abbr_exceptsubcommand_arg jj m main

    _fish_abbr_jj_subcommand "a" "abandon"
    _fish_abbr_jj_subcommand "e" "edit"
    _fish_abbr_jj_subcommand "l" "log"
    _fish_abbr_jj_subcommand "m" "bookmark set main"
    _fish_abbr_jj_subcommand "n" "new"
    _fish_abbr_jj_subcommand "s" "status"
    _fish_abbr_jj_subcommand "sq" "squash"

    _fish_abbr_jj_subcommand "b" "bookmark"
    _fish_abbr_jj_subcommand "bs" "bookmark set"
    _fish_abbr_jj_subcommand "bl" "bookmark list"
    abbr_subcommand_arg jj s set bookmark
    abbr_subcommand_arg jj l list bookmark

    _fish_abbr_jj_subcommand "r" "rebase"
    _fish_abbr_jj_subcommand "rd" "rebase --destination"
    abbr_subcommand_arg jj d --destination rebase

    abbr_subcommand_arg jj ii --ignore-immutable edit squash
    abbr_subcommand_arg jj r --revision bookmark

    _fish_abbr_jj_subcommand "de" "describe"
    abbr -a jdd --set-cursor "jj describe --message \"%" # Special shortened abbreviation

    _fish_abbr_jj_subcommand "gf" "git fetch"
    _fish_abbr_jj_subcommand "p" "git push"
    _fish_abbr_jj_subcommand "gp" "git push"
    abbr -a "jpp" "jj bookmark set main && jj git push"

    _fish_abbr_jj_subcommand "d" "diff"
    abbr_subcommand_arg jj no --name-only diff
    abbr -a jdno --set-cursor "jj diff --name-only --to \"fork_point(%)\"" # Special shortened abbreviation

    function gg
        /Applications/gg.app/Contents/MacOS/gg $argv &> /dev/null &
        disown
        osascript -e 'tell application "System Events" to tell process "gg" to set frontmost to true'
    end

    # Note that this implementing this for `j ci` and `j c i` would require
    # rewriting the commandline (to add the `env` invocation at the beginning)
    # rather than a simple expansion. So we just define `jci` for now.
    abbr -a "jci" 'env VISUAL="cat" jj commit --interactive'
