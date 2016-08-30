source $__fish_datadir/completions/git.fish

### Git completion hacks for Chromium

    function in_chromium_repo
      if not git rev-parse ^ /dev/null
        false
      else if [ (git remote get-url origin) = "https://chromium.googlesource.com/chromium/src.git" ]
        true
      else
        false
      end
    end

    function __fish_git_tags
      if in_chromium_repo
        # I currently don't use tags. Save a bunch of extra time by ignoring.
        # Uncomment the line below to list tags but ignore thousands of release tags.
        # command git tag | grep -v "^\d\+\.\d\+\.\d\+\.\d\+\$"
      else
        command git tag
      end
    end

    function __fish_git_modified_files
      if in_chromium_repo
        # sloooooow. untracked-cache doesn't seem to work.
      else
        # git diff --name-only hands us filenames relative to the git toplevel
        set -l root (command git rev-parse --show-toplevel)
        # Print files from the current $PWD as-is, prepend all others with ":/" (relative to toplevel in git-speak)
        # This is a bit simplistic but finding the lowest common directory and then replacing everything else in $PWD with ".." is a bit annoying
        string replace -- "$PWD/" "" "$root/"(command git diff --name-only ^/dev/null) | string replace "$root/" ":/"
      end
    end

    function __fish_git_branches
      if in_chromium_repo
        # Ignore a whole bunch of release branches.
        command git branch --no-color ^/dev/null | grep -v ' -> ' | sed -e 's/^..//' -e 's/^remotes\///'
      else
        command git branch --no-color -a ^/dev/null | grep -v ' -> ' | sed -e 's/^..//' -e 's/^remotes\///'
      end
    end

    function __fish_git_unique_remote_branches
      if in_chromium_repo
        # Remote branches are useful sometimes, but let's cut them out for performance.
      else
        command git branch --no-color -a $argv ^/dev/null | string match -r -v ' -> ' | string trim -c "* " | string replace -r "^remotes/[^/]*/" "" | sort | uniq -u
      end
    end

    function __fish_git_commits
      if in_chromium_repo 
        # Performance is atrocious if we list all Chromium commit hashes.
      else
        command git log --pretty=tformat:"%h"\t"%s" --all ^/dev/null \
        | string replace -r '(.{73}).+' '$1…'
      end
    end
