## jj

    abbr -a j "jj"

    # m⎵ → main
    abbr_exceptsubcommand_arg jj m main

    abbr -a "jb" "jj bookmark"
    abbr_subcommand jj b bookmark
    abbr_subcommand jj bs "bookmark set"
    abbr_subcommand_arg jj s set bookmark
    abbr -a "jbs" "jj bookmark set"
    abbr -a "jm" "jj bookmark set main"

    abbr -a "je" "jj edit"
    abbr_subcommand jj e edit

    abbr -a "js" "jj status"
    abbr_subcommand jj s status

    abbr -a "jn" "jj new"
    abbr_subcommand jj n new

    abbr -a "jd" "jj diff"

    abbr -a "jde" "jj describe"
    abbr_subcommand jj de describe
    abbr -a jdd --set-cursor "jj describe --message \"%" # Special shortened abbreviation

    abbr -a "jl" "jj log"
    abbr_subcommand jj l log

    abbr -a "jgp" "jj git push"
    abbr_subcommand jj gp "git push"
    abbr -a "jp" "jj git push"
