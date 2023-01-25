## Git

    # # Core abbreviations
    # abbr -a gs    "git status"
    # abbr -a gl    "git log"
    #
    # abbr -a gd    "git diff --color-words"
    # abbr -a gdc   "git diff --color-words --cached"
    # abbr -a gdno  "git diff --name-only"
    #
    # abbr -a gst   "git stage"
    # abbr -a grh   "git reset HEAD"
    # abbr -a gc    "git commit --message"
    # abbr -a gca   "git commit --amend"
    #
    # abbr -a gr    "git rebase"

    abbr -a g    "git"

    abbr -a gs    "git status"
    abbr -a gl    "git log"
    abbr -a glp   "# Try: gl p"

    abbr -a gd    "git diff --color-words"
    abbr -a gdc   "git diff --color-words --cached"

    abbr -a gst   "git stage"
    abbr -a g.    "git stage ."
    abbr -a gsp   "git stage --patch"
    abbr -a cm    --set-cursor "git commit --message \"%" # Special shortened abbreviation
    abbr -a gc    "# Try: gcom / cm"
    abbr -a gcom  "git commit"
    abbr -a gca   "# Try: gc a"
    abbr -a gcane "# Try: gc ane"

    function _lga_gcv
        echo "git commit --message \""(pbpaste)
        echo ""
        echo "Release notes:"
        echo ""
        echo "- %\""
    end
    abbr -a gcv --set-cursor --function _lga_gcv

    abbr -a gb    "git branch"
    abbr -a gbd   "# Try: gb d"
    abbr -a gbm   "git branch -m"
    abbr -a gco   "git checkout"
    abbr -a gcb   "git checkout -b"
    abbr -a gcp   "git cherry-pick"
    abbr -a gdno  "git diff --name-only"
    abbr -a gm    "git merge"
    abbr -a gmb   "git merge-base main (git rev-parse --abbrev-ref HEAD)"

### Ref names

    # A lot of `git` commands take branch arguments, so we allow the expansion for all arguments.
    # But we define it first, so that the expansion of `m` can be superseded for specific commands (e.g. `git commit`)
    function _lga_git_anysub_main_fn; _lga_define_exceptsubcommand_arg_expansion \
        main git commit; end
    abbr -a _lga_git_anysub_main --regex m --position anywhere --function _lga_git_anysub_main_fn

    function _lga_git_anysub_origin_main_fn; _lga_define_exceptsubcommand_arg_expansion \
        origin/main git; end
    abbr -a _lga_git_anysub_origin_main --regex om --position anywhere --function _lga_git_anysub_origin_main_fn

    function _lga_git_anysub_master_fn; _lga_define_exceptsubcommand_arg_expansion \
        master git; end
    abbr -a _lga_git_anysub_master --regex ms --position anywhere --function _lga_git_anysub_master_fn

    function _lga_git_anysub_HEAD_fn; \
        set str "HEAD"
        if [ "$argv[1]" != "h" ]
            set str $str"~"(string trim --left --chars=h $argv[1])"%"
        end
        _lga_define_exceptsubcommand_arg_expansion \
        $str git; end
    abbr -a _lga_git_anysub_HEAD --regex "h[0-9]*" --position anywhere --function _lga_git_anysub_HEAD_fn \
        --set-cursor

### Subcommands

    function _lga_git_merge_fn; _lga_define_subcommand_expansion \
        merge git m; end
    abbr -a _lga_git_merge --regex m --position anywhere --function _lga_git_merge_fn

    function _lga_git_rebase_fn; _lga_define_subcommand_expansion \
        rebase git r; end
    abbr -a _lga_git_rebase --regex r --position anywhere --function _lga_git_rebase_fn

    function _lga_git_branch_fn; _lga_define_subcommand_expansion \
        branch git b; end
    abbr -a _lga_git_branch --regex b --position anywhere --function _lga_git_branch_fn

    function _lga_git_push_fn; _lga_define_subcommand_expansion \
        push git p; end
    abbr -a _lga_git_push --regex p --position anywhere --function _lga_git_push_fn

### Subcommand arguments: re-entrant (rebase merge cherry-pick)

    set -g git_reentrant rebase merge cherry-pick
    function _lga_git_sub_reentrant_abort_fn; _lga_define_subcommand_arg_expansion \
        "--abort" git $git_reentrant; end

    abbr -a _lga_git_sub_reentrant_abort --regex a --position anywhere --function _lga_git_sub_reentrant_abort_fn
    function _lga_git_sub_reentrant_abort_fn; _lga_define_subcommand_arg_expansion \
        "--abort" git $git_reentrant; end
    abbr -a _lga_git_sub_reentrant_abort --regex a --position anywhere --function _lga_git_sub_reentrant_abort_fn

    function _lga_git_sub_reentrant_abort_fn; _lga_define_subcommand_arg_expansion \
        "--abort" git $git_reentrant; end
    abbr -a _lga_git_sub_reentrant_abort --regex a --position anywhere --function _lga_git_sub_reentrant_abort_fn

### Subcommand arguments: others

    function _lga_git_sub_rebase_interactive_fn; _lga_define_subcommand_arg_expansion \
        "--interactive" git rebase; end
    abbr -a _lga_git_sub_rebase_interactive --regex i --position anywhere --function _lga_git_sub_rebase_interactive_fn

    function _lga_git_sub_commit_amend_fn; _lga_define_subcommand_arg_expansion \
        "--amend" git commit; end
    abbr -a _lga_git_sub_commit_amend --regex a --position anywhere --function _lga_git_sub_commit_amend_fn

    function _lga_git_sub_commit_no_edit_fn; _lga_define_subcommand_arg_expansion \
        "--no-edit" git commit; end
    abbr -a _lga_git_sub_commit_no_edit --regex ne --position anywhere --function _lga_git_sub_commit_no_edit_fn

    function _lga_git_sub_commit_no_edit_fn; _lga_define_subcommand_arg_expansion \
        "--amend --no-edit" git commit; end
    abbr -a _lga_git_sub_commit_no_edit --regex ane --position anywhere --function _lga_git_sub_commit_no_edit_fn

    function _lga_git_sub_commit_message_fn; _lga_define_subcommand_arg_expansion \
        "--message \"%\"" git commit; end
    abbr -a _lga_git_sub_commit_message --regex m --position anywhere --function _lga_git_sub_commit_message_fn \
        --set-cursor

    function _lga_commit_last_command
        echo git commit --message "\"`$history[1]`\""
    end
    abbr -a gc!! --position anywhere --function _lga_commit_last_command

    # git log pretty, from http://www.xerxesb.com/2010/command-line-replacement-for-gitk/
    function _lga_git_sub_log_pretty_fn; _lga_define_subcommand_arg_expansion \
        "--oneline --decorate=full --graph --remotes" git log; end
    abbr -a _lga_git_sub_log_pretty --regex p --position anywhere --function _lga_git_sub_log_pretty_fn

    function _lga_git_sub_push_origin_fn; _lga_define_subcommand_arg_expansion \
        "origin" git push; end
    abbr -a _lga_git_sub_push_origin --regex o --position anywhere --function _lga_git_sub_push_origin_fn

    function _lga_git_sub_push_upstream_fn; _lga_define_subcommand_arg_expansion \
        "upstream" git push; end
    abbr -a _lga_git_sub_push_upstream --regex u --position anywhere --function _lga_git_sub_push_upstream_fn

    function _lga_git_sub_push_tags_fn; _lga_define_subcommand_arg_expansion \
        "--tags" git push; end
    abbr -a _lga_git_sub_push_tags --regex t --position anywhere --function _lga_git_sub_push_tags_fn

    function _lga_git_sub_push_force_with_lease_fn; _lga_define_subcommand_arg_expansion \
        "--force-with-lease" git push; end
    abbr -a _lga_git_sub_push_force_with_lease --regex fl --position anywhere --function _lga_git_sub_push_force_with_lease_fn

    function _lga_git_sub_branch_delete_fn; _lga_define_subcommand_arg_expansion \
        "-D" git branch; end
    abbr -a _lga_git_sub_branch_delete --regex d --position anywhere --function _lga_git_sub_branch_delete_fn

    function _lga_git_sub_tag_delete_fn; _lga_define_subcommand_arg_expansion \
        "-d" git tag; end
    abbr -a _lga_git_sub_tag_delete --regex d --position anywhere --function _lga_git_sub_tag_delete_fn

    function _lga_git_sub_merge_no_ff_fn; _lga_define_subcommand_arg_expansion \
        "--no-ff" git merge; end
    abbr -a _lga_git_sub_merge_no_ff --regex nff --position anywhere --function _lga_git_sub_merge_no_ff_fn

    function _lga_git_sub_merge_ff_only_fn; _lga_define_subcommand_arg_expansion \
        "--ff-only" git merge; end
    abbr -a _lga_git_sub_merge_ff_only --regex ffo --position anywhere --function _lga_git_sub_merge_ff_only_fn

    # abbr -a gcfd  "git clean --force -d" # subsumed by `gclean`

    abbr -a grh   "git reset HEAD"
    abbr -a ghard "git reset --hard"
    abbr -a gsoft "git reset --soft"
    abbr -a gr    "git rebase"
    abbr -a gri   "# Try: gr i"
    abbr -a gr3   "# gr i h3"
    abbr -a gr9   "# gr i h9"
    abbr -a grm   "# Try: gr m"
    abbr -a grom  "# Try: gr om"
    abbr -a gsh   "git show HEAD"

    abbr -a nff "# Try: g nff"
    abbr -a ffo "# Try: g ffo"

    abbr -a gt   "git tag"
    abbr -a gtd  "# Try: gt d"

    abbr -a gv "gh repo view --web --branch (git rev-parse --abbrev-ref HEAD)"

    abbr -a gfp   "git fetch --prune"
    abbr -a gp    "git push"
    abbr -a gpo   "# Try: gp o"
    abbr -a gpot  "# Try: gp o t"
    abbr -a gpfl  "# Try: gp fl"
    abbr -a gu    "git pull"
    abbr -a grv   "git remote --verbose"
    function pr
        echo -n "pull/$argv[1]/head"
    end

    abbr -a gf    "git freeze"
    abbr -a gth   "git thaw"

    # "git push branch" to a remote that doesn't know about the branch yet.
    abbr -a gph "git push -u origin HEAD"
    abbr -a gbak "git push -f --all bak"

    abbr -a upstream "git rev-parse --abbrev-ref --symbolic-full-name \"@{upstream}\""

    function gpr
       set -l url
       set -l branch (git rev-parse --abbrev-ref HEAD)
       if test $status -eq 0
           set url (hub pr list -f "%U" -h $branch)
       end

       if test -z $url
           set url (hub browse -u)
       end

       python -mwebbrowser $url >/dev/null
    end

    # Distance between branches.
    function dist
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
        --command dist \
        --arguments '(__fish_git_branches)'

    abbr -a gbranch "git rev-parse --abbrev-ref HEAD"
    abbr -a ghash "git rev-parse HEAD"
    abbr -a gmessage "git log -1 --pretty=%B"

    function gclean
        echo "Use: `ga` (`git abandon`)"
    end
    abbr -a ga "git abandon"

    if which gitx > /dev/null
        abbr -a gx "gitx"
    else
        abbr -a gx "open -a GitX ."
    end

    function rmbranch
        set BRANCH $argv[1]
        echo "Branch `$BRANCH` was at: "(git rev-parse $BRANCH)
        git push origin :$BRANCH
        git branch -D $BRANCH
    end
    complete -c rmbranch -f
    # From https://codybonney.com/getting-a-list-of-local-git-branches-without-using-git-branch/
    complete -c rmbranch -a "(git for-each-ref --format '%(refname:short)' refs/heads/)"

### `tagpush`

    function rmtag
        set TAG $argv[1]
        git tag -d $TAG; or echo "Did not need to remove tag locally"
        echo "--------"
        git push origin :$TAG; or echo "Did not need to remove tag from origin"
    end

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
