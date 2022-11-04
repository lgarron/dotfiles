## `dev`

    abbr -a m "make"
    abbr -a mb "make build"
    abbr -a mc "make clean"
    abbr -a md "make dev"
    abbr -a mdp "make deploy"
    function ml
        echo "Use: mdp"
    end
    abbr -a mp "make publish"
    abbr -a mt "make test"
    abbr -a mf "make format"
    abbr -a mcd "make clean dev"
    abbr -a mcb "make clean build"

## `node`

    abbr -a niy "npm init -y"
    abbr -a ni "npm install;"
    abbr -a nis "npm install --save"
    abbr -a nid "npm install --save-dev"
    abbr -a nu "npm uninstall"
    abbr -a nrd "npm run dev"
    abbr -a rmnm "rm -rf ./node_modules ; and npm install"
    abbr -a wtr "npx web-test-runner"

    function bump-version
      # /usr/bin/env echo -n v
      npm version --no-git-tag-version $argv[1]
    end

    abbr -a "yarn" "npx yarn"
    set -xg "EXPERIMENTAL_CUBING_JS_RELOAD_CHROME_MACOS" "1"

## Web

    # *h*ttps *h*eaders
    abbr -a "hh" "https -ph"
