## Git

    abbr -a g    "git"

    abbr -a gs    "git status"
    abbr -a gl    "git log"
    abbr -a glp   "git log --oneline --decorate=full --graph --remotes" # git log pretty, from http://www.xerxesb.com/2010/command-line-replacement-for-gitk/

    abbr -a gd    "git diff --color-words"
    abbr -a gdc   "git diff --color-words --cached"

    abbr -a gst   "git stage"
    abbr -a gc    "git commit --message"
    abbr -a gca   "git commit --amend"
    abbr -a gcane "git commit --amend --no-edit"

    abbr -a gb    "git branch"
    abbr -a gbd   "git branch -D"
    abbr -a gco   "git checkout"
    abbr -a gcb   "git checkout -b"
    abbr -a gcp   "git cherry-pick"
    abbr -a gdno  "git diff --name-only"
    abbr -a gm    "git merge"

    # abbr -a gcfd  "git clean --force -d" # subsumed by `gclean`

    abbr -a grh   "git reset HEAD"
    abbr -a ghard "git reset --hard"
    abbr -a gsoft "git reset --soft"
    abbr -a gr    "git rebase"
    abbr -a gri   "git rebase --interactive"
    abbr -a grm   "git rebase main"
    abbr -a gra   "git rebase --abort"
    abbr -a grom  "git rebase origin/main"
    abbr -a groma "git rebase origin/master"
    abbr -a glast "echo \"Use `gsh`\""
    abbr -a gsh   "git show HEAD"

    abbr -a nff "git merge --no-ff"
    abbr -a ffo "git merge --ff-only"

    abbr -a gt   "git tag"
    abbr -a gtd  "git tag -d"

    abbr -a gv "gh repo view --web --branch (git rev-parse --abbrev-ref HEAD)"

    abbr -a gfp   "git fetch --prune"
    abbr -a gp    "git push"
    abbr -a gpo   "git push origin"
    abbr -a gpot  "git push origin --tags"
    abbr -a gpfl  "git push --force-with-lease"
    abbr -a grv   "git remote --verbose"
    function pr
        echo -n "pull/$argv[1]/head"
    end

    abbr -a gf    "git freeze"

    # "git push branch" to a remote that doesn't know about the branch yet.
    abbr -a gph "git push -u origin HEAD"
    function gpb
        echo "Please use `gph` instead of `gpb`!"
    end

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

    # function gitx
    #   echo "Invoking wrapped gitx."
    #   env DYLD_INSERT_LIBRARIES='' command gitx $argv
    # end
    if which gitx
        abbr -a gx "gitx"
    else
        abbr -a gx "open -a GitX ."
    end
