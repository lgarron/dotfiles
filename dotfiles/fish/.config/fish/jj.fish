## jj

abbr -a j jj

function _fish_abbr_jj_subcommand
    set -l abbrevation $argv[1]
    set -l expansion $argv[2]
    abbr -a "j$abbrevation" "jj $expansion"
    abbr_subcommand jj $abbrevation $expansion
end

# m⎵ → main
abbr_exceptsubcommand_arg jj m main
abbr_exceptsubcommand_arg jj h here

_fish_abbr_jj_subcommand a abandon
_fish_abbr_jj_subcommand e edit
_fish_abbr_jj_subcommand l log
_fish_abbr_jj_subcommand m "bookmark set main"
_fish_abbr_jj_subcommand n new
_fish_abbr_jj_subcommand s status
_fish_abbr_jj_subcommand st status
_fish_abbr_jj_subcommand sq squash
_fish_abbr_jj_subcommand u undo
_fish_abbr_jj_subcommand t tug

_fish_abbr_jj_subcommand b bookmark
_fish_abbr_jj_subcommand bs "bookmark set"
_fish_abbr_jj_subcommand bl "bookmark list"
_fish_abbr_jj_subcommand bd "bookmark delete"
abbr_subcommand_arg jj s set bookmark
abbr_subcommand_arg jj l list bookmark
abbr_subcommand_arg jj d delete bookmark
abbr_subcommand_arg jj ab --allow-backwards bookmark # TODO: can we scope this to `jj bookmark set`?

_fish_abbr_jj_subcommand r rebase
_fish_abbr_jj_subcommand rd "rebase --destination"
abbr_subcommand_arg jj d --destination rebase
abbr_subcommand_arg jj s --source rebase

abbr_subcommand_arg jj ii --ignore-immutable edit squash describe
abbr_subcommand_arg jj r --revision bookmark

_fish_abbr_jj_subcommand de describe
abbr -a jd --set-cursor "jj describe --message \"%" # Special shortened abbreviation
abbr_subcommand_arg jj m --message describe

_fish_abbr_jj_subcommand gf "git fetch"
_fish_abbr_jj_subcommand gfm "git fetch && jj new main@origin"
_fish_abbr_jj_subcommand p "git push"
_fish_abbr_jj_subcommand gp "git push"
abbr -a jpm "jj bookmark set --revision here main && jj git push && git switch main || jj new main"
abbr -a jpt "set FIRST_BOOKMARK (jj guess-branch) && jj bookmark set --revision here \$FIRST_BOOKMARK && jj git push --bookmark \$FIRST_BOOKMARK && git switch \$FIRST_BOOKMARK || jj new \$FIRST_BOOKMARK"
_fish_abbr_jj_subcommand gr "git remote"
_fish_abbr_jj_subcommand grl "git remote list"
abbr_subcommand_arg jj an --allow-new git # TODO: can we scope this to `jj git push`?
abbr_subcommand_arg jj b --bookmark git # TODO: can we scope this to `jj git push`?
abbr_subcommand_arg jj bm "--bookmark main" git # TODO: can we scope this to `jj git push`?
abbr -a jpbm "jj git push --bookmark main"

abbr -a jdd "# try: jd"
_fish_abbr_jj_subcommand di diff
abbr_subcommand_arg jj no --name-only diff
_fish_abbr_jj_subcommand dt "diff --to"
abbr_subcommand_arg jj t --to diff
abbr -a jdno --set-cursor "jj diff --name-only --to \"fork_point(%)\"" # Special shortened abbreviation

# "jj GitHub view"
abbr -a jgv 'open --url (jj git remote list | grep "^origin" | awk "{print \$2}" | tr -d "\n" | sed "s#\.git\$##"; and echo -n "/commit/"; echo -- (jj here))'
# "jj GitHub (view) branch"
abbr -a jgb 'open --url (jj git remote list | grep "^origin" | awk "{print \$2}" | tr -d "\n" | sed "s#\.git\$##"; and echo -n "/commit/"; echo -- (jj guess-branch))'

# LSP override: This is an "exported" function (meant to be used outside this file).
# @fish-lsp-disable-next-line 4004
function gg
    if string match --quiet --entire -- (repo vcs kind) git
        echo "This repo uses `git` but not `jj`. Opening GitX instead."
        gx
        return
    end
    killall gg
    ggn
end

function ggn
    /Applications/gg.app/Contents/MacOS/gg $argv &>/dev/null &
    disown
    $HOME/Code/git/github.com/lgarron/dotfiles/scripts/system/dell-display-position-app-on-bottom.fish gg
    open -a gg # Foreground.
end

# Note that this implementing this for `j ci` and `j c i` would require
# rewriting the commandline (to add the `env` invocation at the beginning)
# rather than a simple expansion. So we just define `jci` for now.
_fish_abbr_jj_subcommand ci 'commit --interactive --config=ui.editor=\'"true"\''

# See: https://github.com/jj-vcs/jj/discussions/6224#discussioncomment-12713147
# NOTE: This has severe limitations.
# LSP override: This is an "exported" function (meant to be used outside this file).
# @fish-lsp-disable-next-line 4004
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

# Interacts with the `fish` prompt `postexec`.
set -g _FISH_JJ_WAS_RUN_DURING_COMMAND false
set -g _FISH_OVERRIDE_DO_NOT_RUN_GG_REFRESH_IN_POSTEXEC false
function jj
    command jj $argv
    set -g _FISH_JJ_WAS_RUN_DURING_COMMAND true
end

# LSP override: This is an "exported" function (meant to be used outside this file).
# @fish-lsp-disable-next-line 4004
function _fish_postexec_refresh_gg_calculate_if_needed
    if _fish_is_true "$_FISH_JJ_WAS_RUN_DURING_COMMAND"
        if not _fish_is_true "$_FISH_OVERRIDE_DO_NOT_RUN_GG_REFRESH_IN_POSTEXEC"
            echo -n true
            return
        end
    end
    echo -n false
end

# LSP override: This is an "exported" function (meant to be used outside this file).
# @fish-lsp-disable-next-line 4004
function _fish_postexec_refresh_gg_if_needed
    if _fish_is_true "$_FISH_JJ_WAS_RUN_DURING_COMMAND"
        if not _fish_is_true "$_FISH_OVERRIDE_DO_NOT_RUN_GG_REFRESH_IN_POSTEXEC"
            if command -qv gg-refresh
                if _fish_strings_are_identical $argv[1] --fancy
                    # Overflowing is unlikely and not the end of the world, so allow it in order to get unbuffered `gg-refresh` output.
                    echo -n "├─ "
                end
                gg-refresh
            else
                echo "⚠️ Could not refresh `gg`."
            end
        end
    end
end

# LSP override: This is an "exported" function (meant to be used outside this file).
# @fish-lsp-disable-next-line 4004
function _fish_postexec_refresh_gg_reset
    set -g _FISH_JJ_WAS_RUN_DURING_COMMAND false
    set -g _FISH_OVERRIDE_DO_NOT_RUN_GG_REFRESH_IN_POSTEXEC false
end
