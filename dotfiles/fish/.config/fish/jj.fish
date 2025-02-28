## jj

    abbr -a j "jj"

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

    abbr -a "gg" "open -a gg ."

    abbr -a "jgp" "jj git push"
    abbr_subcommand jj gp "git push"
