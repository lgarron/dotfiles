## `dev`

    abbr -a m "make"
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
    set -xg "EXPERIMENTAL_CUBING_JS_RELOAD_CHROME_MACOS" "1"

## Web

    # *h*ttps *h*eaders
    abbr -a "hh" "https -ph"

## Misc

    abbr -a "cx" "chmod +x"
