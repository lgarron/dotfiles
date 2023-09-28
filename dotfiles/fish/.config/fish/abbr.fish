
### Abbrevation definition helpers

    set CURRY_COUNTER 1
    function abbr_next_curried_function_name
      echo "_curried_$CURRY_COUNTER"
      set CURRY_COUNTER (math $CURRY_COUNTER + 1)
    end

    function _curry
      set HELPER (abbr_next_curried_function_name)
      # store args in a global var (since fish can't capture vars function definitions)
      set -g "$HELPER"_argv $argv
      function "$HELPER"
        # retrieve global vars
        set HELPER_ARGV (status current-function)_argv
        $$HELPER_ARGV
      end
      echo $HELPER
    end

    function _curry_abbr
      set abbreviation $argv[3]
      set HELPER (_curry $argv)
      abbr -a "$HELPER"_abbr --regex $abbreviation --position anywhere --function "$HELPER"
    end

    # For more detailed examples, see: https://github.com/fish-shell/fish-shell/issues/9411#issuecomment-1397950277

    # Define an abbreviation that can be used in any arg position.
    # For example, `make` targets can appear in any order:
    #
    # - make b⎵ → make build
    # - make c⎵ → make clean
    # - make c⎵ b⎵ → make clean build
    #
    # Example implementations:
    #
    #     abbr_anyarg make b build
    #     abbr_anyarg make c clean
    #
    function _abbr_expand_anyarg
        set main_command $argv[1]
        # set command_abbreviation $argv[2] # unused
        set expansion $argv[3]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command ]
            echo $expansion
            return 0
        end
        return 1
    end
    function abbr_anyarg
      _curry_abbr _abbr_expand_anyarg $argv
    end
    

    # Define a subcommand, i.e. something that must be used as the first
    # argument to a command. For example, the `git` command is built around
    # subcommands:
    #
    # - git p⎵ → git push
    # - git m⎵ → git merge
    #
    # But:
    #
    # - git checkout m⎵ → (not expanded to `git checkout merge`)
    #
    # Example implementations:
    #
    #     abbr_subcommand git p push
    #     abbr_subcommand git m merge
    #
    # To implement an argument for *all* subcommands of a given command, use
    # `abbr_anysubcommand_arg` (see below).
    #
    function _abbr_expand_subcommand
        set main_command $argv[1]
        set sub_command_abbreviation $argv[2]
        set expansion $argv[3]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command -a (count $cmd) -eq 2 -a "$cmd[2]" = $sub_command_abbreviation ]
            echo $expansion
            return 0
        end
        return 1
    end
    function abbr_subcommand
      _curry_abbr _abbr_expand_subcommand $argv
    end

    # Define a subcommand argument, i.e. an argument that can only follow certain subcommands.
    # For example, `git` has different arguments for each subcommand:
    #
    #  - git branch m⎵ → git branch --move
    #  - git commit m⎵ → git commit --message
    #
    # Example implementations:
    #
    #     abbr_subcommand_arg git m "--move" branch
    #     abbr_subcommand_arg git m "--message" commit
    #
    # Multiple commands can also be specified together. For example, the following can be defined at once:
    #
    # - git rebase      c⎵ → git rebase      --continue
    # - git merge       c⎵ → git merge       --continue
    # - git cherry-pick c⎵ → git cherry-pick --continue
    #
    # Example implementation:
    #
    #     abbr_subcommand_arg git c "--continue" rebase merge cherry-pick
    #
    function _abbr_expand_subcommand_arg
        set main_command $argv[1]
        # set arg_abbreviation $argv[2] # unused
        set arg_expansion $argv[3]
        set sub_commands $argv[4..-1]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command ]
            if contains -- "$cmd[2]" $sub_commands
                echo $arg_expansion
                return 0
            end
        end
        return 1
    end
    function abbr_subcommand_arg
      _curry_abbr _abbr_expand_subcommand_arg $argv
    end

    # Define a subcommand argument using a denylist. This is like
    # `_abbr_expand_subcommand_arg`, but instead of allowing it as an argument
    # for the given subcommands, it will work for all subcommands *except* the
    # listed ones.
    #
    # For example, `m` → `main` is a useful branch name expansion for most `git`
    # subcommands. But it would conflict with `git commit m` → `git commit
    # --message` (see above). This function lets you exclude `git commit`
    # without having to specify a large list of `git` subcommands explicitly:
    #
    #  - git checkout m⎵ → git checkout main
    #  - git merge m⎵ → git merge main
    #  - git log m⎵ → git log main
    #
    # But:
    #
    #  - git commit m⎵ → (not expanded to `git commit main`)
    #
    # Example implementation:
    #
    #     abbr_exceptsubcommand_arg git m main commit
    #
    function _abbr_expand_exceptsubcommand_arg
        set main_command $argv[1]
        # set arg_abbreviation $argv[2] # unused
        set arg_expansion $argv[3]
        set excluded_sub_commands $argv[4..-1]
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = $main_command -a (count $cmd) -gt 2 ]
            if not contains -- "$cmd[2]" $excluded_sub_commands
                echo $arg_expansion
                return 0
            end
        end
        return 1
    end
    function abbr_exceptsubcommand_arg
      _curry_abbr _abbr_expand_exceptsubcommand_arg $argv
    end
    # Convenience
    function abbr_anysubcommand_arg
      if [ (count $argv) -gt 3 ]
        echo "ERROR: abbr_anysubcommand_arg does not take denylist arguments"
        return 1
      end
      _curry_abbr _abbr_expand_exceptsubcommand_arg $argv[1..3]
    end
