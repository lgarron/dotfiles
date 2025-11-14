## Git

    abbr -a g "git"

### Helpers

    abbr -a gmessage  "git log -1 --pretty=%B"
    abbr -a gbranch   "git rev-parse --abbrev-ref HEAD"
    abbr -a ghash     "git rev-parse HEAD"
    abbr -a gupstream "git rev-parse --abbrev-ref --symbolic-full-name \"@{upstream}\"" # TODO: remove?

### Ref name abbreviations

    # m⎵ → main
    #
    # A lot of `git` commands take branch arguments, so we allow the expansion for all arguments.
    # But we define it first, so that the expansion of `m` can be superseded for specific commands (e.g. `git commit`)
    # We also explicitly exclude `git commit` as a known conflict, just in case.
    abbr_exceptsubcommand_arg git m main branch commit
    # p⎵ → production
    abbr_exceptsubcommand_arg git p production branch commit
    # ms⎵ → master
    abbr_exceptsubcommand_arg git ms master commit
    # lf⎵ refs/last-freeze
    abbr_exceptsubcommand_arg git lf refs/last-freeze commit

    # b⎵ → (expansion of current branch name)
    # function _abbr_git_currentbranch_fn; _abbr_expand_exceptsubcommand_arg (git rev-parse --abbrev-ref HEAD) git; end; abbr -a _abbr_git_currentbranch --regex b --position anywhere --function _abbr_git_currentbranch_f
    # :b⎵ → :(expansion of current branch name)
    function _abbr_git_coloncurrentbranch_fn
        _abbr_expand_subcommand_arg git :b :(git rev-parse --abbrev-ref HEAD) push
    end
    abbr -a _abbr_git_coloncurrentbranch --regex :b --position anywhere --function _abbr_git_coloncurrentbranch_fn
    function _abbr_git_coloncurrentbranch1_fn
        _abbr_expand_subcommand_arg git :b1 :(git rev-parse --abbrev-ref @{-1}) push
    end
    abbr -a _abbr_git_coloncurrentbranch1 --regex :b1 --position anywhere --function _abbr_git_coloncurrentbranch1_fn
    function _abbr_git_coloncurrentbranch2_fn
        _abbr_expand_subcommand_arg git :b2 :(git rev-parse --abbrev-ref @{-2}) push
    end
    abbr -a _abbr_git_coloncurrentbranch2 --regex :b2 --position anywhere --function _abbr_git_coloncurrentbranch2_fn

    # om⎵ → origin/main
    abbr_exceptsubcommand_arg git om origin/main commit
    # op⎵ → origin/production
    abbr_exceptsubcommand_arg git op origin/production commit
    # oms⎵ → origin/master
    abbr_exceptsubcommand_arg git oms origin/master commit
    # ob⎵ → origin/(expansion of current branch name)
    function _abbr_git_origincurrentbranch_fn
        _abbr_expand_exceptsubcommand_arg git ob origin/(git rev-parse --abbrev-ref HEAD) commit
    end
    abbr -a _abbr_git_origincurrentbranch --regex ob --position anywhere --function _abbr_git_origincurrentbranch_fn

    # um⎵ → upstream/main
    abbr_exceptsubcommand_arg git um upstream/main commit
    # up⎵ → upstream/production
    abbr_exceptsubcommand_arg git up upstream/production commit
    # ums⎵ → upstream/master
    abbr_exceptsubcommand_arg git ums upstream/master commit
    # ub⎵ → upstream/(expansion of current branch name)
    function _abbr_git_upstreamcurrentbranch_fn
        _abbr_expand_exceptsubcommand_arg git ub upstream/(git rev-parse --abbrev-ref HEAD) git
    end
    abbr -a _abbr_git_upstreamcurrentbranch --regex ub --position anywhere --function _abbr_git_upstreamcurrentbranch_fn

    # b-⎵ → (expansion of last branch name)
    function _abbr_git_lastbranch_fn
        _abbr_expand_exceptsubcommand_arg git b- (git rev-parse --abbrev-ref @{-1}) commit
    end
    abbr -a _abbr_git_lastbranch --regex b- --position anywhere --function _abbr_git_lastbranch_fn

    function _abbr_rmbranch_lastbranch_fn
        _abbr_expand_anyarg rmbranch b- (git rev-parse --abbrev-ref @{-1})
    end
    abbr -a _abbr_rmbranch_lastbranch --regex b- --position anywhere --function _abbr_rmbranch_lastbranch_fn

    function _fish_branchhist_expansion
        set branch_abbreviation $argv[1]
        set ref "@"
        if [ "$branch_abbreviation" != "b" ]
            set ref $ref"{-"(string trim --left --chars=b $argv[1])"}"
        end
        echo (git rev-parse --abbrev-ref $ref 2>/dev/null); or return 1
    end

    #  b⎵ → (expansion of current branch name)
    # b1⎵ → (expansion of last branch name)
    # b3⎵ → (expansion of three branch names ago)
    function _abbr_git_branchhist_fn
        _abbr_expand_exceptsubcommand_arg git _ (_fish_branchhist_expansion $argv[1]) commit
    end
    abbr -a _abbr_git_branchhist --regex "b[0-9]*" --position anywhere --function _abbr_git_branchhist_fn

    function _abbr_rmbranch_branchhist_fn
        _abbr_expand_anyarg rmbranch _ (_fish_branchhist_expansion $argv[1])
    end
    abbr -a _abbr_rmbranch_branchhist --regex "b[0-9]*" --position anywhere --function _abbr_rmbranch_branchhist_fn

    #   h⎵ → HEAD
    #  h1⎵ → HEAD~1
    # h12⎵ → HEAD~12
    function _abbr_git_HEAD_fn
        set str "HEAD"
        if [ "$argv[1]" != "h" ]
            set str $str"~"(string trim --left --chars=h $argv[1])
        end
        _abbr_expand_exceptsubcommand_arg git _ $str commit;
    end
    abbr -a _abbr_git_HEAD --regex "h[0-9]*" --position anywhere --function _abbr_git_HEAD_fn

    #  m1⎵ → main~1
    # m12⎵ → main~12
    function _abbr_git_mainhist_fn
        set str "main"
        if [ "$argv[1]" != "m" ]
            set str $str"~"(string trim --left --chars=m $argv[1])
        end
        _abbr_expand_exceptsubcommand_arg git _ $str commit;
    end
    abbr -a _abbr_git_mainhist --regex "m[0-9]+" --position anywhere --function _abbr_git_mainhist_fn

### git add

    abbr -a ga  "git add"
    abbr -a gap "git add --patch" # second-level convenience
    abbr -a g.  "git add ."

    # git add p⎵ → git add --patch
    abbr_subcommand_arg git p "--patch" add

### git branch

    # git b⎵ → git branch
    abbr_subcommand git b branch

    abbr -a gb  "git branch"
    abbr -a gbd "# Try: gb df"
    abbr -a gbm "# Try: gb m"

    # git branch m⎵ → git branch --move
    abbr_subcommand_firstarg git m "--move" branch
    # git branch d⎵ → git branch --delete
    abbr_subcommand_firstarg git d "--delete" branch
    # git branch df⎵ → git branch --delete --force (equivalent to: git branch -D)
    abbr_subcommand_firstarg git df "--delete --force" branch

### git checkout

    abbr -a gco "# Try: gw / ge"
    abbr -a gcb "# Try: gw c"

### git cherry-pick

    abbr -a gcp "git cherry-pick"

### git commit

    abbr -a gc                "git commit"
    abbr -a gcom              "# Try: gc"
    abbr -a gca               "git commit --amend"
    abbr -a cm   --set-cursor "git commit --message \"%" # Special shortened abbreviation
    # Legacy
    abbr -a gcane "git commit --amend --no-edit"

    abbr -a ggg "git commit --amend --no-edit && git push --force-with-lease"
    abbr -a gggg "git status && read -p \"echo \\\"Press enter to continue (Ctrl-C to abort)\\\"\" &&
git stage . &&
git commit --amend --no-edit &&
git push --force-with-lease"

    # git commit a⎵ → git commit --amend
    abbr_subcommand_arg git a "--amend" commit
    # git commit ne⎵ → git commit --no-edit
    abbr_subcommand_arg git ne "--no-edit" commit
    # git commit ne⎵ → git commit --allow-empty
    abbr_subcommand_arg git ae "--allow-empty" commit
    # git commit m⎵ → git commit --message "%" ( TODO: remove the second space?)
    function _abbr_git_commit_message_fn; _abbr_expand_subcommand_arg git m "--message \"%\"" commit; end; abbr -a _abbr_git_commit_message --regex m --position anywhere --function _abbr_git_commit_message_fn --set-cursor
    # git commit !!⎵ → git commit --message "`[last command]`" ( TODO: remove the second space?)
    function _abbr_git_commit_last_command_fn; _abbr_expand_subcommand_arg git !! "--message \"`"(string replace --all "\"" "\\\"" $history[1])"`\"" commit; end; abbr -a _abbr_git_commit_last_command --regex !! --position anywhere --function _abbr_git_commit_last_command_fn
    # git commit !!!⎵ → git commit --message "`[second-to-last command]`" ( TODO: remove the second space?)
    function _abbr_git_commit_secondlast_command_fn; _abbr_expand_subcommand_arg git !!! "--message \"`"(string replace --all "\"" "\\\"" $history[2])"`\"" commit; end; abbr -a _abbr_git_commit_secondlast_command --regex !!! --position anywhere --function _abbr_git_commit_secondlast_command_fn
    # git commit !!!!⎵ → git commit --message "`[third-to-last command]`" ( TODO: remove the second space?)
    function _abbr_git_commit_thirdlast_command_fn; _abbr_expand_subcommand_arg git !!! "--message \"`"(string replace --all "\"" "\\\"" $history[3])"`\"" commit; end; abbr -a _abbr_git_commit_thirdlast_command --regex !!! --position anywhere --function _abbr_git_commit_thirdlast_command_fn

    # Also see: `jdv` (in `jj.fish`)
    function _abbr_gcv
        echo "git commit --message \""(repo version get)
        echo ""
        echo "Release notes:"
        echo ""
        echo "- %"
    end
    abbr -a gcv --function _abbr_gcv --set-cursor

### git diff

    abbr -a gd "git diff"
    abbr -a gdc "git diff --cached" # second-level convenience
    abbr -a gdno "git diff --name-only"

    # git diff c⎵ → git diff --cached
    abbr_subcommand_arg git c "--cached" diff
    # git diff no⎵ → git diff --name-only
    abbr_subcommand_arg git no "--name-only" diff

    abbr -a gdnm "git diff --name-only (git merge-base main (git rev-parse --abbrev-ref HEAD))"

### git fetch

    abbr -a gf "git fetch"
    abbr -a gfp "git fetch --prune"

    abbr_subcommand_arg git p "--prune" fetch

### git log

    abbr -a gl  "git log"
    abbr -a glp "# Try: gl p"

    # git log pretty, from http://www.xerxesb.com/2010/command-line-replacement-for-gitk/
    # git log p⎵ → git log [several arguments for a nice, condensed output]
    abbr_subcommand_arg git p "--oneline --decorate=full --graph --remotes" log

### git merge

    # git m⎵ → git merge
    abbr_subcommand git m merge

    abbr -a gm  "git merge"
    abbr -a nff "git merge --no-ff"
    abbr -a ffo "git merge --ff-only"

    # git merge nff⎵ → git merge --no-ff
    abbr_subcommand_arg git nff "--no-ff" merge
    # git merge ffo⎵ → git merge --ff-only
    abbr_subcommand_arg git ffo "--ff-only" merge

### git merge

    # git mb⎵ → git merge-base
    abbr_subcommand git m merge

    abbr -a gmb "git merge-base"
    abbr -a gmbmb "git merge-base main (git rev-parse --abbrev-ref HEAD)"

### git pull

    abbr -a gu "git pull"

### git push

    # git p⎵ → git push
    abbr_subcommand git p push

    abbr -a gp   "git push"
    abbr -a gph  "git push -u origin HEAD" # "git push branch" to a remote that doesn't know about the branch yet.
    abbr -a gbak "git push -f --all bak"
    abbr -a gpfl "git push --force-with-lease # 🗻"
    # Legacy
    abbr -a gpo  "git push origin"
    abbr -a gpot "# Try: gp o t"

    # git push t⎵ → git push --tags
    abbr_subcommand_arg git t "--tags" push
    # git push fl⎵ → git push --force-with-lease
    abbr_subcommand_arg git fl "--force-with-lease" push

### git rebase

    # git r⎵ → git rebase
    abbr_subcommand git r rebase

    abbr -a gr "git rebase"
    # Legacy
    abbr -a gri  "# Try: gr i"
    abbr -a gr3  "# Try: gr i h3"
    abbr -a gr9  "# Try: gr i h9"
    abbr -a grm  "# Try: gr m"
    abbr -a grom "# Try: gr om"

    # git rebase i⎵ → git rebase --interactive
    abbr_subcommand_arg git i "--interactive" rebase
    abbr_subcommand_arg git 2 "--interactive HEAD~2" rebase
    abbr_subcommand_arg git 3 "--interactive HEAD~3" rebase
    abbr_subcommand_arg git 4 "--interactive HEAD~4" rebase
    abbr_subcommand_arg git 5 "--interactive HEAD~5" rebase
    abbr_subcommand_arg git 6 "--interactive HEAD~6" rebase
    abbr_subcommand_arg git 7 "--interactive HEAD~7" rebase
    abbr_subcommand_arg git 8 "--interactive HEAD~8" rebase
    abbr_subcommand_arg git 9 "--interactive HEAD~9" rebase

### git remote

    abbr -a grv "git remote --verbose"

### git reset

    abbr -a grh   "git reset HEAD"
    abbr -a h.    "git reset HEAD ." # Note that this doesn't delete any unsaved data (on its own).
    abbr -a ghard "# Try: ghr"
    abbr -a ghr   "git reset --hard" # Shorter abbreviation
    abbr -a gsoft "git reset --soft"

### git switch

    abbr -a gw "git switch"  # *g*it s**itch
    abbr -a gwc "# try: g+"
    abbr -a g+ "git switch --create"
    abbr -a "gj" "git switch --create" # alias for `g+` that doesn't need ⇧
    abbr -a gwd "# try: g-"
    abbr -a g- "git switch --detach"

    # git switch c⎵ → git switch --create
    abbr_subcommand_arg git c "--create" switch

    # git switch d⎵ → git switch --detach
    abbr_subcommand_arg git d "--detach" switch


### git show

    abbr -a gsh "git show HEAD"

    # git show s⎵ → git show --summary
    abbr_subcommand_arg git s "--summary" show

### git stash

    abbr -a gst "git stash"
    abbr -a st "git stash"
    abbr -a stp "git stash pop"

    abbr_subcommand git st "stash"
    abbr_subcommand git stash "# Try: `st`"

    abbr_subcommand_arg git p "pop" stash
    abbr_subcommand_arg git s "show" stash
    abbr_subcommand_arg git d "drop" stash

### git status

    abbr -a gs "git status"

### git switch

    abbr -a ge "git restore"  # *g*it r*e*store
    abbr -a ges "git restore --source"  # *g*it r*e*store

    abbr -a ged "git restore --detach"  # *g*it r*e*store
    abbr_subcommand_arg git d "--detach" restore

    abbr_subcommand_arg git s "--source" restore
    # abbr -a gem "git restore --source HEAD" Conflict with the `gem` command.
    abbr_subcommand_arg git m "--source main" restore
    abbr -a geh "git restore --source HEAD"
    abbr_subcommand_arg git h "--source HEAD" restore
    abbr -a gelf "git restore --source refs/last-freeze"
    abbr_subcommand_arg git lf "--source refs/last-freeze" restore

### git tag

    abbr -a gt "git tag"
    # Legacy
    abbr -a gtd "# Try: gt d"

    # git tag d⎵ → git tag --delete (equivalent to: git tag -D)
    abbr_subcommand_firstarg git d "--delete" tag

### Repo-sensitive subcommand arguments (shared)
###
### - git fetch
### - git pull
### - git push

    set -g git_subcommands_repo_sensitive \
        fetch \
        pull \
        push

    # git push o⎵ → git push origin
    abbr_subcommand_arg git o "origin" $git_subcommands_repo_sensitive
    # git push u⎵ → git push upstream
    abbr_subcommand_arg git u "upstream" $git_subcommands_repo_sensitive

### Re-entrant subcommand arguments (shared)
###
### - git cherry-pick
### - git rebase
### - git merge

    set -g git_subcommands_reentrant \
        rebase \
        merge \
        cherry-pick

    # git rebase a⎵ →⎵git rebase --abort
    abbr_subcommand_firstarg git a "--abort" $git_subcommands_reentrant
    # git rebase c⎵ →⎵git rebase --continue
    abbr_subcommand_firstarg git c "--continue" $git_subcommands_reentrant

## gh (GitHub CLI)

    abbr -a gv "gh repo view --web --branch (git rev-parse --abbrev-ref HEAD)"
    abbr -a gpr "# Try: gpv"
    abbr -a gpv "gh pr view --web"

## git freeze (https://github.com/lgarron/git-freeze)

    abbr -a gfr "git freeze"
    abbr -a gth "git thaw"
    abbr -a gab "git abandon"

## Related command abbreviations

    abbr -a "tp" "tagpush"
    abbr_anyarg tagpush r "--retag"
    abbr -a rmb "rmbranch"
    abbr -a rmt "rmtag"

## Functions

### dist

    abbr -a dist "git distance"

    complete --no-files \
        --command git \
        --arguments distance \
        --arguments '(__fish_git_branches)'

## GitX

    # LSP override: This is an "exported" function (meant to be used outside this file).
    # @fish-lsp-disable-next-line 4004
    function gx
        open -a GitX . & ; disown
        $HOME/Code/git/github.com/lgarron/dotfiles/scripts/system/dell-display-position-app-on-bottom.ts GitX
    end
