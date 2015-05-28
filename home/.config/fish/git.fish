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

    abbr -a grh   "git reset HEAD"
    abbr -a gr    "git rebase"
    abbr -a glast "git show HEAD"

    abbr -a gp    "git push"
    abbr -a pr    "git fetch origin pull/ID/head:newBranchName"

    function gitx
      env DYLD_INSERT_LIBRARIES='' /usr/local/bin/gitx $argv
    end
    abbr -a gx    "gitx --256 &"

    function switch-chrome-user
      set -x USER $argv[1]
      osascript -e '
        tell application "System Events"
          tell process "Google Chrome"
            click menu item "'"$USER"'" of menu "People" of menu bar 1
        end tell
      end tell'
    end

    function github
      if not git remote -v | grep github > /dev/null
        switch-chrome-user "chromium"
        echo "Opening on https://codereview.chromium.org/"
        git cl web &
      else
        switch-chrome-user "creasepattern"
        echo "Opening on GitHub.com"
        hub browse &
      end
    end

    abbr -a gh github
