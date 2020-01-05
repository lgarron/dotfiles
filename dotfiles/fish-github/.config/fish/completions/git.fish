    source $__fish_datadir/completions/git.fish

### Git completion hacks

    function in_slow_repo
      if not git rev-parse ^ /dev/null
        false
      else if [ (git remote get-url origin) = "https://github.com/github/github" ]
        true
      else
        false
      end
    end

    functions -c __fish_git_tags __default__fish_git_tags
    function __fish_git_tags
      if not in_slow_repo
        __default__fish_git_tags
      end
    end

    functions -c __fish_git_branches __default__fish_git_branches
    function __fish_git_branches
      if not in_slow_repo
        __default__fish_git_branches
      else 
        command git branch --no-color $argv ^/dev/null | string match -v '\* (*)' | string match -r -v ' -> ' | string trim -c "* " | string replace -r "^remotes/" ""
      end
    end

    functions -c __fish_git_remote_branches __default__fish_git_remote_branches
    function __fish_git_remote_branches
      if not in_slow_repo
        __default__fish_git_remote_branches
      end
    end

    functions -c __fish_git_unique_remote_branches __default__fish_git_unique_remote_branches
    function __fish_git_unique_remote_branches
      if not in_slow_repo
        __default__fish_git_unique_remote_branches
      end
    end

    functions -c __fish_git_commits __default__fish_git_commits
    function __fish_git_commits
      if not in_slow_repo
        __default__fish_git_commits
      end
    end

    functions -c __fish_git_heads __default__fish_git_heads
    function __fish_git_heads
      if not in_slow_repo
        __default__fish_git_heads
      end
    end

    functions -c __fish_git_possible_commithash __default__fish_git_possible_commithash
    function __fish_git_possible_commithash
      if not in_slow_repo
        __default__fish_git_possible_commithash
      end
    end

    functions -c __fish_git_reflog __default__fish_git_reflog
    function __fish_git_reflog
      if not in_slow_repo
        __default__fish_git_reflog
      end
    end

