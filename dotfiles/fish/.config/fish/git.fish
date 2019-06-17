## Git

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
    abbr -a gco   "git checkout"
    abbr -a gcb   "git checkout -b"
    abbr -a gcp   "git cherry-pick"
    abbr -a gdno  "git diff --name-only"

    abbr -a gcfd  "git clean --force -d"

    abbr -a grh   "git reset HEAD"
    abbr -a ghard "git reset --hard"
    abbr -a gsoft "git reset --soft"
    abbr -a gr    "git rebase"
    abbr -a gri   "git rebase --interactive"
    abbr -a grom  "git rebase origin/master"
    abbr -a glast "echo \"Use `gsh`\""
    abbr -a gsh   "git show HEAD"

    abbr -a gp    "git push"
    abbr -a gpfl  "git push --force-with-lease"
    abbr -a grv   "git remote --verbose"
    function pr
        echo -n "pull/$argv[1]/head"
    end

    # "git push branch" to a remote that doesn't know about the branch yet.
    abbr -a gpb   "git push -u origin (git rev-parse --abbrev-ref HEAD)"

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
        set HASH (git rev-parse HEAD)
        # TODO: This requires depot_tools
        git freeze
        git update-ref refs/last-freeze HEAD
        git log --pretty=oneline $HASH...HEAD
        git reset --hard $HASH
    end

    function gitx
      echo "Invoking wrapped gitx."
      env DYLD_INSERT_LIBRARIES='' command gitx $argv
    end
    abbr -a gx    "gitx --256 &"

    function github
        hub browse &
    end
    abbr -a gh github
