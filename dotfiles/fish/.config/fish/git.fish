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
    abbr -a glast "echo \"Use `gsh`\""
    abbr -a gsh   "git show HEAD"

    abbr -a gp    "git push"
    abbr -a grv   "git remote --verbose"
    abbr -a pr    "git fetch origin pull/ID/head:newBranchName"

    # "git push branch" to a remote that doesn't know about the branch yet.
    abbr -a gpb   "git push -u origin (git rev-parse --abbrev-ref HEAD)"

    abbr -a ghash "git rev-parse HEAD"

    function gnuke
        git reset --hard
        git checkout .
        git clean -fd
    end

    function gitx
      echo "Invoking wrapped gitx."
      env DYLD_INSERT_LIBRARIES='' command gitx $argv
    end
    abbr -a gx    "gitx --256 &"

    if contains (hostname -s) $NOETHER
        abbr -a gmb "git-map-branches -vv"
    end

    function github
        hub browse &
    end
    abbr -a gh github
