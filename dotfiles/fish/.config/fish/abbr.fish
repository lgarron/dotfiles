### Abbrevation definition helpers

    # Quick examples:
    #
    #     abbr_anyarg make b build
    #     abbr_anyarg make c clean
    #
    #     abbr_subcommand git p push
    #     abbr_subcommand git m merge
    #
    #     abbr_subcommand_arg git m "--message" commit
    #     abbr_subcommand_arg git p "--patch" add
    #     abbr_subcommand_arg git c --continue rebase merge cherry-pick
    #
    #     abbr_subcommand_firstarg git m "--move" branch
    #
    #     abbr_exceptsubcommand_arg git m main commit
    #
    # See below for more details
    #

    ################################

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
    function abbr_anyarg
      _curry_abbr _abbr_expand_anyarg $argv
    end
    function _abbr_expand_anyarg
        set -l main_command $argv[1]
        # set -l command_abbreviation $argv[2] # unused
        set -l expansion $argv[3]
        set -l cmd (commandline -op)
        if test "$cmd[1]" = $main_command
            echo $expansion
            return 0
        end
        return 1
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
    function abbr_subcommand
      _curry_abbr _abbr_expand_subcommand $argv
    end

    function _abbr_expand_subcommand
      set -l main_command $argv[1]
      set -l sub_command_abbreviation $argv[2]
      set -l expansion $argv[3]
      set -l cmd (commandline -op)
      if string match -e -- "$cmd[1]" "$main_command" > /dev/null
        if test (count $cmd) -eq 2
          if string match -e -- "$cmd[2]" "$sub_command_abbreviation" > /dev/null
            echo $expansion
            return 0
          end
        end
      end
      return 1
    end

    # Define a subcommand argument, i.e. an argument that can only follow certain subcommands.
    # For example, `git` has different arguments for each subcommand:
    #
    #  - git commit m⎵ → git commit --message
    #  - git add p⎵ → git add --patch
    #
    # Example implementations:
    #
    #     abbr_subcommand_arg git m "--message" commit
    #     abbr_subcommand_arg git p "--patch" add
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
    # To implement an argument for *all* subcommands of a given command, use
    # `abbr_anysubcommand_arg` (see below).
    #
    function abbr_subcommand_arg
      _curry_abbr _abbr_expand_subcommand_arg $argv
    end

    function _abbr_expand_subcommand_arg
      set -l main_command $argv[1]
      # set -l arg_abbreviation $argv[2] # unused
      set -l arg_expansion $argv[3]
      set -l sub_commands $argv[4..-2]
      set -l cmd (commandline -op)
      if string match -e -- "$cmd[1]" "$main_command" > /dev/null
        if contains -- "$cmd[2]" $sub_commands
          echo $arg_expansion
          return 0
        end
      end
      return 1
    end

    # Define a subcommand argument that expands only if it's the *first* argument.
    # This is useful for large CLIs where each subcommand essentially has "sub-subcommands". For example:
    #
    #  - git branch m⎵ → git branch --move
    #  - git branch --move m⎵ → (not expanded to `git branch --move --move`)
    #
    # Example implementations:
    #
    #     abbr_subcommand_firstarg git m "--move" branch
    #
    function abbr_subcommand_firstarg
      _curry_abbr _abbr_expand_subcommand_firstarg $argv
    end

    function _abbr_expand_subcommand_firstarg
        set -l main_command $argv[1]
        set -l arg_abbreviation $argv[2]
        set -l arg_expansion $argv[3]
        set -l sub_commands $argv[4..-2]
        set -l cmd (commandline -op)
        if string match -e -- "$cmd[1]" "$main_command" > /dev/null
          if test (count $cmd) = 3
            if string match -e -- "$cmd[3]" "$arg_abbreviation" > /dev/null
              if contains -- "$cmd[2]" $sub_commands
                  echo $arg_expansion
                  return 0
              end
            end
          end
        end
        return 1
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
    # Note: If you combine this with the `abbr_subcommand_firstarg git m "--move" branch` example from above,
    # then you can expand `git branch m⎵ m⎵` to `git branch --move main`.
    #
    function abbr_exceptsubcommand_arg
      _curry_abbr _abbr_expand_exceptsubcommand_arg $argv
    end

    # Convenience
    function abbr_anysubcommand_arg
      if test (count $argv) -gt 3
        echo "ERROR: abbr_anysubcommand_arg does not take denylist arguments"
        return 1
      end
      _curry_abbr _abbr_expand_exceptsubcommand_arg $argv[1..3]
    end

    function _abbr_expand_exceptsubcommand_arg
      set -l main_command $argv[1]
      # set -l arg_abbreviation $argv[2] # unused
      set -l arg_expansion $argv[3]
      set -l excluded_sub_commands $argv[4..-2]
      set -l cmd (commandline -op)
      if string match -e -- "$cmd[1]" "$main_command" > /dev/null
        if test (count $cmd) -gt 2
          if not contains -- "$cmd[2]" $excluded_sub_commands
            echo $arg_expansion
            return 0
          end
        end
      end
      return 1
    end

    # 🪄 Currying ✨

    set _CURRY_COUNTER 1
    function _curry
      set -l CURRIED_FN "_curried_fn_$_CURRY_COUNTER"
      set _CURRY_COUNTER (math $_CURRY_COUNTER + 1)
      
      set -l INHERITED_ARGS $argv
      function "$CURRIED_FN" --inherit-variable INHERITED_ARGS
        $INHERITED_ARGS $argv
      end
      echo $CURRIED_FN
    end

    function _curry_abbr
      set -l abbreviation $argv[3]
      set -l CURRIED_FN (_curry $argv)
      abbr -a "$CURRIED_FN"_abbr --regex $abbreviation --position anywhere --function "$CURRIED_FN"
    end
