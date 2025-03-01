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
    _fish_abbr_jj_subcommand "gp" "git push"
    _fish_abbr_jj_subcommand "l" "log"
    _fish_abbr_jj_subcommand "m" "bookmark set main"
    _fish_abbr_jj_subcommand "n" "new"
    _fish_abbr_jj_subcommand "p" "git push"
    _fish_abbr_jj_subcommand "s" "status"

    _fish_abbr_jj_subcommand "b" "bookmark"
    _fish_abbr_jj_subcommand "bs" "bookmark set"
    abbr_subcommand_arg jj s set bookmark

    _fish_abbr_jj_subcommand "de" "describe"
    abbr -a jdd --set-cursor "jj describe --message \"%" # Special shortened abbreviation

    abbr -a "jpp" "jj bookmark set main && jj git push"

    _fish_abbr_jj_subcommand "d" "diff"
    abbr_subcommand_arg jj no --name-only diff
    abbr -a jdno --set-cursor "jj diff --name-only --to \"fork_point(%)\"" # Special shortened abbreviation
