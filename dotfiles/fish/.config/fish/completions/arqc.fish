complete -c arqc -f

set -l arq_subcommands activateLicense refreshLicense deactivateLicense setAppPassword listBackupPlans latestBackupActivityLog latestBackupActivityJSON startBackupPlan stopBackupPlan pauseBackups resumeBackups
complete -c arqc -n "not __fish_seen_subcommand_from $arq_subcommands" -a "$arq_subcommands"

complete -c arqc -n "__fish_seen_subcommand_from latestBackupActivityLog latestBackupActivityJSON startBackupPlan stopBackupPlan" \
    -a "(arqc listBackupPlans 2> /dev/null | grep \"^UUID=\" | sed \"s/^UUID=//g\")" # We can just allow the first tab of `listBackupPlans` to be interpreted by `fish` as a separator between value and description.
