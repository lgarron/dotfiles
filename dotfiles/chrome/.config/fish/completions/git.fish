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

    functions -c __fish_git_tags __default_fish_git_tags
    function __fish_git_tags
      if in_chromium_repo
        # I currently don't use tags. Save a bunch of extra time by ignoring.
        # Uncomment the line below to list tags but ignore thousands of release tags.
        # command git tag | grep -v "^\d\+\.\d\+\.\d\+\.\d\+\$" 
      else
        __default_fish_git_tags
      end
    end

    functions -c __fish_git_modified_files __default_fish_git_modified_files
    function __fish_git_modified_files
      if in_chromium_repo
        # sloooooow. untracked-cache doesn't seem to work.
      else
        __default_fish_git_modified_files
      end
    end

    functions -c __fish_git_branches __default_fish_git_branches
    function __fish_git_branches
      if in_chromium_repo
        # Ignore a whole bunch of release branches.
        command git branch --no-color ^/dev/null | grep -v ' -> ' | sed -e 's/^..//' -e 's/^remotes\///'
      else
        __default_fish_git_branches
      end
    end

    functions -c __fish_git_unique_remote_branches __default_fish_git_unique_remote_branches
    function __fish_git_unique_remote_branches
      if in_chromium_repo
        # Remote branches are useful sometimes, but let's cut them out for performance.
      else
        __default_fish_git_unique_remote_branches
      end
    end

    functions -c __fish_git_commits __default_fish_git_commits
    function __fish_git_commits
      if in_chromium_repo 
        # Performance is atrocious if we list all Chromium commit hashes.
      else
        __default_fish_git_commits
      end
    end

