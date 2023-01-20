## `dev`

    abbr -a --position command m "make"

    function _lg_complete_make_b_function
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = make ]
            echo "build"
            return 0
        end
        return 1
    end
    abbr -a _lg_complete_make_b --regex b --position anywhere --function _lg_complete_make_b_function

    function _lg_complete_make_d_function
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = make ]
            echo "dev"
            return 0
        end
        return 1
    end
    abbr -a _lg_complete_make_d --regex d --position anywhere --function _lg_complete_make_d_function

    function _lg_complete_make_c_function
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = make ]
            echo "clean"
            return 0
        end
        return 1
    end
    abbr -a _lg_complete_make_c --regex c --position anywhere --function _lg_complete_make_c_function

    abbr -a mb "make build"
    abbr -a mc "make clean"
    abbr -a md "make dev"
    abbr -a mdp "make deploy"
    abbr -a mp "make publish"
    abbr -a mt "make test"
    abbr -a ml "make lint"
    abbr -a mf "make format"
    abbr -a mcd "make clean dev"
    abbr -a mcb "make clean build"

## `node`

    abbr -a niy "npm init -y ; and jq --indent 2 '.type=\"module\" | del(.main)' package.json > /tmp/package.json ; and cat /tmp/package.json > package.json"
    abbr -a ni "npm install;"
    abbr -a nis "npm install --save"
    abbr -a nid "npm install --save-dev"
    abbr -a nu "npm uninstall"
    abbr -a nr "npm run"
    abbr -a rmnm "rm -rf ./node_modules ; and npm install"
    abbr -a wtr "npx web-test-runner"

    abbr -a "es2020" "npx esbuild --format=esm --target=es2020 --bundle --splitting --outdir=dist/esm-bundle"

    function bump-version
      # /usr/bin/env echo -n v
      npm version --no-git-tag-version $argv[1]
    end

    abbr -a "yarn" "npx yarn"
    # https://github.com/cubing/cubing.js/blob/3597fba81b65a1c87e42c4297a2d9ef5fdc3a8e3/script/build/targets.js#L44
    set -xg "EXPERIMENTAL_CUBING_JS_RELOAD_CHROME_MACOS" "1"

    function _lg_complete_npm_run_d_function
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = npm ]
            if contains -- "$cmd[2]" run; echo "dev"; return 0; end
        end
        return 1
    end
    abbr -a _lg_complete_npm_run_d --regex d --position anywhere --function _lg_complete_npm_run_d_function

    function _lg_complete_npm_run_b_function
        set -l cmd (commandline -op)
        if [ "$cmd[1]" = npm ]
            if contains -- "$cmd[2]" run; echo "build"; return 0; end
        end
        return 1
    end
    abbr -a _lg_complete_npm_run_b --regex b --position anywhere --function _lg_complete_npm_run_b_function

## Web

    # *h*ttps *h*eaders
    abbr -a "hh" "https -ph"

## Misc

    abbr -a "cx" "chmod +x"
