function cd-dir
    set INPUT_PATH $argv[1]
    set -g _LATEST_CD_DIR_PATH $INPUT_PATH
    if not test -d $INPUT_PATH
        set INPUT_PATH (dirname $INPUT_PATH)
    end
    cd $INPUT_PATH
end
