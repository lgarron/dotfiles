## Git

    abbr -a g    "git"

### Helpers

    abbr -a gmessage "git log -1 --pretty=%B"
    abbr -a gbranch  "git rev-parse --abbrev-ref HEAD"
    abbr -a ghash    "git rev-parse HEAD"
    abbr -a upstream "git rev-parse --abbrev-ref --symbolic-full-name \"@{upstream}\""

    function pr
        echo -n "pull/$argv[1]/head"
    end

### Ref name abbreviations

    # m⎵ → main
    #
    # A lot of `git` commands take branch arguments, so we allow the expansion for all arguments.
    # But we define it first, so that the expansion of `m` can be superseded for specific commands (e.g. `git commit`)
    function _lga_git_main_fn; _lga_define_exceptsubcommand_arg_expansion \ main git commit; end; abbr -a _lga_git_main --regex m --position anywhere --function _lga_git_main_fn

    # om⎵ → origin/master
    function _lga_git_origin_main_fn; _lga_define_exceptsubcommand_arg_expansion \ origin/main git; end; abbr -a _lga_git_origin_main --regex om --position anywhere --function _lga_git_origin_main_fn

    # ms⎵ → master
    function _lga_git_master_fn; _lga_define_exceptsubcommand_arg_expansion \ master git; end; abbr -a _lga_git_master --regex ms --position anywhere --function _lga_git_master_fn

    #   h⎵ → HEAD
    #  h1⎵ → HEAD~1
    # h12⎵ → HEAD~12
    function _lga_git_HEAD_fn; \
        set str "HEAD"
        if [ "$argv[1]" != "h" ]
            set str $str"~"(string trim --left --chars=h $argv[1])"%"
        end
        _lga_define_exceptsubcommand_arg_expansion \ $str git;
    end
    abbr -a _lga_git_HEAD --regex "h[0-9]*" --position anywhere --function _lga_git_HEAD_fn --set-cursor

### git add

    abbr -a ga  "git add"
    abbr -a g.  "git add ."
    # Legacy
    abbr -a gst "# Try: ga"
    abbr -a gsp "# Try: ga p"

    # git add p⎵ → git add --patch
    function _lga_git_add_patch_fn; _lga_define_subcommand_arg_expansion \ "--patch" git add; end; abbr -a _lga_git_add_patch --regex p --position anywhere --function _lga_git_add_patch_fn

### git branch

    abbr -a gb  "git branch"
    abbr -a gbd "# Try: gb df"
    abbr -a gbm "# Try: gb m"

    function _lga_git_branch_fn; _lga_define_subcommand_expansion \ branch git b; end; abbr -a _lga_git_branch --regex b --position anywhere --function _lga_git_branch_fn

    # git branch m⎵ → git branch --move
    function _lga_git_branch_move_fn; _lga_define_subcommand_arg_expansion \ "--move" git branch; end; abbr -a _lga_git_branch_move --regex m --position anywhere --function _lga_git_branch_move_fn
    # git branch d⎵ → git branch --delete --force (equivalent to: git branch -D)
    function _lga_git_branch_delete_fn; _lga_define_subcommand_arg_expansion \ "--delete --force" git branch; end; abbr -a _lga_git_branch_delete --regex d --position anywhere --function _lga_git_branch_delete_fn

### git checkout

    abbr -a gco   "git checkout"
    abbr -a gcb   "git checkout -b"

### git cherry-pick

    abbr -a gcp   "git cherry-pick"

### git commit

    abbr -a gcom            "git commit"
    abbr -a gca             "git commit --amend"
    abbr -a cm --set-cursor "git commit --message \"%" # Special shortened abbreviation
    # Legacy
    abbr -a gc              "# Try: gcom / cm"
    abbr -a gcane           "# Try: gca ne"

    function _lga_git_commit_amend_fn; _lga_define_subcommand_arg_expansion \ "--amend" git commit; end; abbr -a _lga_git_commit_amend --regex a --position anywhere --function _lga_git_commit_amend_fn
    function _lga_git_commit_no_edit_fn; _lga_define_subcommand_arg_expansion \ "--no-edit" git commit; end; abbr -a _lga_git_commit_no_edit --regex ne --position anywhere --function _lga_git_commit_no_edit_fn
    function _lga_git_commit_message_fn; _lga_define_subcommand_arg_expansion \ "--message \"%\"" git commit; end; abbr -a _lga_git_commit_message --regex m --position anywhere --function _lga_git_commit_message_fn --set-cursor
    function _lga_git_commit_last_command_fn; _lga_define_subcommand_arg_expansion \ "--message \"`"(string replace --all "\"" "\\\"" $history[1])"`\"" git commit; end; abbr -a _lga_git_commit_last_command --regex !! --position anywhere --function _lga_git_commit_last_command_fn

    function js_version
        echo -n "v"; cat package.json | jq -r ".version"
    end
    function _lga_gcv
        echo "git commit --message \""(js_version)
        echo ""
        echo "Release notes:"
        echo ""
        echo "- %\""
    end
    abbr -a gcv --set-cursor --function _lga_gcv

### git diff

    abbr -a gd   "git diff --color-words"
    abbr -a gdc  "git diff --color-words --cached" # TODO
    abbr -a gdno "git diff --name-only" # TODO

### git fetch

    abbr -a gfp   "git fetch --prune"

### git log

    abbr -a gl  "git log"
    abbr -a glp "# Try: gl p"

    # git log pretty, from http://www.xerxesb.com/2010/command-line-replacement-for-gitk/
    function _lga_git_log_pretty_fn; _lga_define_subcommand_arg_expansion \ "--oneline --decorate=full --graph --remotes" git log; end; abbr -a _lga_git_log_pretty --regex p --position anywhere --function _lga_git_log_pretty_fn

### git merge

    # git m⎵ → git merge
    function _lga_git_merge_fn; _lga_define_subcommand_expansion \ merge git m; end; abbr -a _lga_git_merge --regex m --position anywhere --function _lga_git_merge_fn

    abbr -a gm  "git merge"
    abbr -a gmb "git merge-base main (git rev-parse --abbrev-ref HEAD)"
    # Legacy
    abbr -a nff "# Try: gm nff"
    abbr -a ffo "# Try: gm ffo"

    # git merge nff⎵ → git merge --no-ff
    function _lga_git_merge_no_ff_fn; _lga_define_subcommand_arg_expansion \ "--no-ff" git merge; end; abbr -a _lga_git_merge_no_ff --regex nff --position anywhere --function _lga_git_merge_no_ff_fn
    # git merge ffo⎵ → git merge --ff-only
    function _lga_git_merge_ff_only_fn; _lga_define_subcommand_arg_expansion \ "--ff-only" git merge; end; abbr -a _lga_git_merge_ff_only --regex ffo --position anywhere --function _lga_git_merge_ff_only_fn

### git pull

    abbr -a gu    "git pull"

### git push

    # git p⎵ → git push
    function _lga_git_push_fn; _lga_define_subcommand_expansion \ push git p; end; abbr -a _lga_git_push --regex p --position anywhere --function _lga_git_push_fn

    abbr -a gp   "git push"
    abbr -a gph  "git push -u origin HEAD" # "git push branch" to a remote that doesn't know about the branch yet.
    abbr -a gbak "git push -f --all bak"
    # Legacy
    abbr -a gpo   "# Try: gp o"
    abbr -a gpot  "# Try: gp o t"
    abbr -a gpfl  "# Try: gp fl"

    # git push t⎵ → git push --tags
    function _lga_git_push_tags_fn; _lga_define_subcommand_arg_expansion \ "--tags" git push; end; abbr -a _lga_git_push_tags --regex t --position anywhere --function _lga_git_push_tags_fn
    # git push fl⎵ → git push --force-with-lease
    function _lga_git_push_force_with_lease_fn; _lga_define_subcommand_arg_expansion \ "--force-with-lease" git push; end; abbr -a _lga_git_push_force_with_lease --regex fl --position anywhere --function _lga_git_push_force_with_lease_fn

### git rebase

    # git r⎵ → git rebase
    function _lga_git_rebase_fn; _lga_define_subcommand_expansion \ rebase git r; end; abbr -a _lga_git_rebase --regex r --position anywhere --function _lga_git_rebase_fn

    abbr -a gr    "git rebase"
    # Legacy
    abbr -a gri   "# Try: gr i"
    abbr -a gr3   "# Try: gr i h3"
    abbr -a gr9   "# Try: gr i h9"
    abbr -a grm   "# Try: gr m"
    abbr -a grom  "# Try: gr om"

    # git rebase i⎵ → git rebase --interactive
    function _lga_git_rebase_interactive_fn; _lga_define_subcommand_arg_expansion \ "--interactive" git rebase; end; abbr -a _lga_git_rebase_interactive --regex i --position anywhere --function _lga_git_rebase_interactive_fn

### git remot

    abbr -a grv   "git remote --verbose"

### git reset

    abbr -a grh   "git reset HEAD"
    abbr -a ghard "git reset --hard"
    abbr -a gsoft "git reset --soft"

### git show

    abbr -a gsh   "git show HEAD"

### git status

    abbr -a gs    "git status"

### git tag

    abbr -a gt   "git tag"
    # Legacy
    abbr -a gtd  "# Try: gt d"

    # git tag d⎵ → git tag --delete (equivalent to: git tag -D)
    function _lga_git_tag_delete_fn; _lga_define_subcommand_arg_expansion \ "--delete" git tag; end; abbr -a _lga_git_tag_delete --regex d --position anywhere --function _lga_git_tag_delete_fn

### Repo-sensitive subcommand arguments (shared)
###
### - git pull
### - git push

    set -g git_subcommands_repo_sensitive \
        pull \
        push

    # git push o⎵ → git push origin
    function _lga_git_push_origin_fn; _lga_define_subcommand_arg_expansion \ "origin" git $git_subcommands_repo_sensitive; end; abbr -a _lga_git_push_origin --regex o --position anywhere --function _lga_git_push_origin_fn
    # git push u⎵ → git push upstream
    function _lga_git_push_upstream_fn; _lga_define_subcommand_arg_expansion \ "upstream" git $git_subcommands_repo_sensitive; end; abbr -a _lga_git_push_upstream --regex u --position anywhere --function _lga_git_push_upstream_fn

### Re-entrant subcommand arguments (shared)
###
### - git cherry-pick
### - git rebase
### - git merge

    set -g git_subcommands_reentrant \
        rebase \
        merge \
        cherry-pick

    function _lga_git_reentrant_abort_fn; _lga_define_subcommand_arg_expansion \ "--abort" git $git_subcommands_reentrant; end; abbr -a _lga_git_reentrant_abort --regex a --position anywhere --function _lga_git_reentrant_abort_fn

    function _lga_git_reentrant_continue_fn; _lga_define_subcommand_arg_expansion \ "--continue" git $git_subcommands_reentrant; end; abbr -a _lga_git_reentrant_continue --regex a --position anywhere --function _lga_git_reentrant_continue_fn

## gh (GitHub CLI)

    abbr -a gv "gh repo view --web --branch (git rev-parse --abbrev-ref HEAD)"
    abbr -a gpr "gh pr view --web"

## git freeze (https://github.com/lgarron/git-freeze)

    abbr -a gf  "git freeze"
    abbr -a gth "git thaw"
    abbr -a gab "git abandon"

## Functions

### dist

    abbr -a dist "# Try: gdist"

    # Distance between branches.
    function gdist
        set CURRENT (git rev-parse --abbrev-ref HEAD)
        set OTHER $argv[1]

        git rev-list --left-only --count $CURRENT...$OTHER | tr -d '\n'
        echo -n " commit(s) on "
        set_color -o
        echo "$CURRENT"
        set_color normal

        git rev-list --right-only --count $CURRENT...$OTHER | tr -d '\n'
        echo -n " commit(s) on "
        set_color -o
        echo "$OTHER"
        set_color normal
    end

    complete --no-files \
        --command gdist \
        --arguments '(__fish_git_branches)'

## GitX

    if which gitx > /dev/null
        abbr -a gx "gitx"
    else
        abbr -a gx "open -a GitX ."
    end

## rmbranch

    function rmbranch
        set BRANCH $argv[1]
        echo "Branch `$BRANCH` was at: "(git rev-parse $BRANCH)
        git push origin :$BRANCH
        git branch -D $BRANCH
    end
    complete -c rmbranch -f
    # From https://codybonney.com/getting-a-list-of-local-git-branches-without-using-git-branch/
    complete -c rmbranch -a "(git for-each-ref --format '%(refname:short)' refs/heads/)"

### rmtag

    function rmtag
        set TAG $argv[1]
        git tag -d $TAG; or echo "Did not need to remove tag locally"
        echo "--------"
        git push origin :$TAG; or echo "Did not need to remove tag from origin"
    end

### tagpush

    function tagpush-check
        set VERSION (echo -n "v"; cat package.json | jq -r ".version")
        if test $VERSION = "v"
            echo "No `package.json` to get version." 1>&2
            return 1
        end
        if test $VERSION = "vnull"
            echo "Could not get version from `package.json`." 1>&2
            return 1
        end
        set PREVIOUS_COMMIT_VERSION (echo -n "v"; git show HEAD~:package.json | jq -r ".version")
        if test $VERSION = $PREVIOUS_COMMIT_VERSION
            echo "`package.json` did not change since last commit. Halting `retagpush`." 1>&2
            return 1
        end
    end

    function tagpush-version
        set TAG $argv[1]
        git tag $TAG
        echo "--------"
        git push origin $TAG
    end

    function tagpush
        tagpush-check || return 1
        tagpush-version (echo -n "v"; cat package.json | jq -r ".version")
    end

    function retagpush-version
        set TAG $argv[1]
        echo -n "Tag was previously at at commit: "
        git rev-parse $TAG; or echo "No old tag"
        echo "--------"
        rmtag $TAG
        echo "--------"
        tagpush-version $TAG
    end

    function retagpush
        tagpush-check || return 1
        retagpush-version (echo -n "v"; cat package.json | jq -r ".version")
    end
