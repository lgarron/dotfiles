    source $__fish_data_dir/completions/git.fish

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

    if in_slow_repo
      function __fish_git_tags
      end
    end

    if in_slow_repo
      function __fish_git_branches
        command git branch --no-color $argv ^/dev/null | string match -v '\* (*)' | string match -r -v ' -> ' | string trim -c "* " | string replace -r "^remotes/" ""
      end
    end

    # if in_slow_repo
    #   function __fish_git_unique_remote_branches
    #   end
    # end

    # if in_slow_repo
    #   function __fish_git_commitsts
    #   end
    # end

    # if in_slow_repo
    #   function __fish_git_heads
    #   end
    # end

    # if in_slow_repo
    #   function __fish_git_possible_commithash
    #   end
    # end

    # if in_slow_repo
    #   function __fish_git_reflog
    #   end
    # end

