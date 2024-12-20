# `cd-dir`

    set _LATEST_CD_DIR_PATH $HOME
    function cd-dir
      set INPUT_PATH $argv[1]
      set -g _LATEST_CD_DIR_PATH $INPUT_PATH
      if not test -d $INPUT_PATH
        set INPUT_PATH (dirname $INPUT_PATH)
      end
      cd $INPUT_PATH
    end
    function cd-dir-from-iterm
      set -l NUM_DASHES (math $COLUMNS - 1)
      echo -n (set_color B594E2)"╭"
      string repeat -n $NUM_DASHES "─"
      echo "┴ Launching shell in folder for path:"
      echo ""
      echo (set_color --bold)"$argv[1]"(set_color B594E2)
      echo ""
      if string match --entire -- "$TERM_PROGRAM" "iTerm.app" > /dev/null
          set SHORTCUT "⇧⌘↩"
        else
          set SHORTCUT "^⌥R"
      end
      echo "┬ Use $SHORTCUT to place this into a command."
      echo -n "╰"
      string repeat -n $NUM_DASHES "─"
      echo -n (set_color normal)

      cd-dir $argv[1]
    end
    function cd-dir-from-iterm-base64
      cd-dir-from-iterm (printf %s $argv[1] | base64 --decode)
    end
    function _abbr_latest_cd_dir_path
      if not set -q _LATEST_CD_DIR_PATH
        return 1
      end
      string escape $_LATEST_CD_DIR_PATH
    end
    abbr -a _kk_abbr --regex "kk" --position anywhere --function _abbr_latest_cd_dir_path
