# See: https://github.com/jj-vcs/jj/discussions/6224#discussioncomment-12713147
# NOTE: This has severe limitations.
function jj_soft_reset_accidentally_modified_change
    set TARGET_PARENT_REVISION $argv[1]
    if [ (count $argv) -gt 1 ]
        set CHANGESET_TO_SOFT_RESET $argv[2]
    else
        set CHANGESET_TO_SOFT_RESET "@"
    end
    echo "CHANGESET_TO_SOFT_RESET: $CHANGESET_TO_SOFT_RESET"
    # TODO: is there a way to do this without checking out the changeset? (`jj duplicate` doesn't seem to have a way to specify the revision/changeset?)
    jj edit --ignore-immutable $CHANGESET_TO_SOFT_RESET
    set JJ_DUPLICATE_OUTPUT (jj duplicate 2>&1)
    echo $JJ_DUPLICATE_OUTPUT

    set FROM_COMMIT_ID (echo $JJ_DUPLICATE_OUTPUT | grep -o "^Duplicated [0-9a-f]\+ as [k-z]\+ " | awk "{print \$2}")
    echo "FROM_COMMIT_ID: $FROM_COMMIT_ID"
    set DUPLICATED_CHANGESET_ID (echo $JJ_DUPLICATE_OUTPUT | grep -o "^Duplicated [0-9a-f]\+ as [k-z]\+ " | awk "{print \$4}")
    echo "DUPLICATED_CHANGESET_ID: $DUPLICATED_CHANGESET_ID"

    jj edit $DUPLICATED_CHANGESET_ID
    jj describe --message "(Changes from a soft reset.)"
    # TODO: this doesn't work for revs that are more than 1 ancestor ago. Do the semantics `jj restore` work for this?
    jj rebase --destination $TARGET_PARENT_REVISION
    jj abandon $FROM_COMMIT_ID
end
