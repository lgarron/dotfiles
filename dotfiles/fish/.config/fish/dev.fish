## `dev`

## `make

    abbr -a --position command m "make"
    abbr -a --position command k "mak"

    # Allow the first (and usually the only) target to be combined with the initial `m`:
    # Additional targets can be expanded using the argument abbreviations below.
    abbr -a mb "make build"
    abbr -a mc "make clean"
    abbr -a md "make dev"
    abbr -a mdp "make deploy"
    abbr -a mp "make publish"
    abbr -a mt "make test"
    abbr -a ml "make lint"
    abbr -a mf "make format"
    abbr -a ms "make setup"

    # Chords
    abbr -a mcb "make clean build"

    # `cubing.js` targets I use often.
    abbr -a mta "make test-all"
    abbr -a kta "mak test-all"
    abbr -a mtf "time make -j 16 test-fast"
    abbr -a ktf "mak test-fast"
    # Targets for other programs
    abbr -a kt "mak test"

    for make_command in make mak
        abbr_anyarg $make_command b  build
        abbr_anyarg $make_command d  dev
        abbr_anyarg $make_command c  clean
        abbr_anyarg $make_command dp deploy
        abbr_anyarg $make_command p  publish
        abbr_anyarg $make_command t  test
        abbr_anyarg $make_command l  lint
        abbr_anyarg $make_command f  format
        abbr_anyarg $make_command s  setup

        # Chords
        abbr_anyarg $make_command cb "clean build"

        # `cubing.js` targets I use often.
        abbr_anyarg $make_command ta test-all
        abbr_anyarg $make_command tf test-fast
    end

## JavaScript

    abbr -a n "npm"

    abbr -a niy "npm init -y ; and jq --indent 2 '.type=\"module\" | del(.main)' package.json > /tmp/package.json ; and cat /tmp/package.json > package.json"
    abbr -a ni "npm install;"
    abbr -a nis "npm install --save"
    abbr -a nid "npm install --save-dev"
    abbr -a nr "npm run"
    abbr -a nl "npm link"

    abbr_subcommand npm i install
    abbr_subcommand npm u uninstall
    abbr_subcommand npm r run
    abbr_subcommand npm l link

    # npm install s⎵ → npm install --save
    abbr_subcommand_arg npm s --save install

    # npm install d⎵ → npm install --save-dev
    abbr_subcommand_arg npm d --save-dev install

    # npm run d⎵ → npm run dev
    abbr_subcommand_arg npm d dev run
    # npm run b⎵ → npm run build
    abbr_subcommand_arg npm b build run

    abbr -a rmnm "rm -rf ./node_modules ; and npm install"
    abbr -a wtr "npx web-test-runner"
    abbr -a "yarn" "npx yarn"

    abbr -a "es2020" "npx esbuild --format=esm --target=es2020 --bundle --splitting --sourcemap --outdir=dist/esm-bundle"

    function bump-version
      # /usr/bin/env echo -n v
      npm version --no-git-tag-version $argv[1]
    end

    # https://github.com/cubing/cubing.js/blob/3597fba81b65a1c87e42c4297a2d9ef5fdc3a8e3/script/build/targets.js#L44
    set -xg "EXPERIMENTAL_CUBING_JS_RELOAD_CHROME_MACOS" "1"

    abbr -a b "bun"

    abbr -a bi "bun install;"
    abbr -a ba "bun add"
    abbr -a br "bun run"
    abbr -a bt "bun test"
    abbr -a bx "bun x"

    abbr -a bad "# Try: ba d"
    abbr -a bis "# Try: ba"
    abbr -a bid "# Try: ba d"

    abbr_subcommand bun a add
    abbr_subcommand bun i install
    abbr_subcommand bun r run
    abbr_subcommand bun t test

    # bun add d⎵ → bun add --development
    abbr_subcommand_arg bun d --development add

# Cargo

    abbr -a co "cargo"

    abbr -a ca "cargo add"
    abbr -a cb "cargo build"
    abbr -a cf "cargo fmt"
    abbr -a ct "cargo test"
    abbr -a cr "cargo run --release --" # I need to test release performance more often than debugging.
    abbr -a crq "cargo run --release --quiet --"
    abbr -a crd "cargo run --"
    abbr -a crdq "cargo run --quiet --"
    abbr -a cre "cargo run --release --example"
    abbr -a cred "cargo run --example"
    abbr -a crh "cargo run -- --help"

    abbr_subcommand cargo a add
    abbr_subcommand cargo b build
    abbr_subcommand cargo f fmt
    abbr_subcommand cargo t test
    abbr_subcommand cargo r "run --"

    abbr_anysubcommand_arg cargo p "--package"
    abbr_anysubcommand_arg cargo pt "--package twsearch-cpp-wrapper"

    # cargo build -- r⎵ → cargo build --release
    abbr_subcommand_arg cargo r "--release" build

    # cargo run -- q⎵ → cargo run --quiet
    abbr_subcommand_arg cargo q "--quiet" run
    # cargo run -- h⎵ → cargo run -- --help
    abbr_subcommand_arg cargo h "--help" run

## Web

    # *h*ttps *h*eaders
    abbr -a "hh" "https -ph"

## Misc

    abbr -a "cx" "chmod +x"
    abbr -a "p3" "python3"
    abbr -a "dig" "xdig"
    abbr -a "tf" "terraform"
    abbr -a "sm" "script/manage"
    abbr -a "disk-speed-test" '"/Applications/Blackmagic Disk Speed Test.app/Contents/MacOS/DiskSpeedTest" --cmd --dir'

    abbr -a serve "open http://localhost:8000; caddy file-server --listen :8000 --browse --root ."

    # Workaround for VS Code not using `dev.containers.defaultExtensionsIfInstalledLocally` for codespaces created outside its (interactive ⇒ very slow) UI.
    function codespaces-install-common-extensions
        set -l _CODESPACES_COMMON_EXTENSIONS \
        GitHub.vscode-pull-request-github \
        craigb85.custom-window-zoom \
        eamodio.gitlens \
        stkb.rewrap \
        pranshuagrawal.toggle-case \
        bierner.markdown-preview-github-styles
        for extension_id in $_CODESPACES_COMMON_EXTENSIONS
            code --install-extension $extension_id
        end
        set -Ux _CODESPACES_COMMON_EXTENSIONS_HAVE_BEEN_INSTALLED true
    end
    if set -q CODESPACES
        if not set -q _CODESPACES_COMMON_EXTENSIONS_HAVE_BEEN_INSTALLED
            codespaces-install-common-extensions
        end
    end

    function archive_hevc_10bit
        if [ (count $argv) -lt 2 ]
            echo "Usage example: "(status current-function)" 70 ./input.mp4"
            return 1
        end
        set QUALITY $argv[1]
        set IN $argv[2]
        set OUT $argv[2]".10-bit.qv"$QUALITY".mp4"
        ffmpeg \
            -i $IN \
            # Unsupported and ignored?
            -pix_fmt yuv422p10 \
            # fast encoding
            -c:v hevc_videotoolbox \
            # 10-bit
            -profile:v main10 \
            # Needed to play in Quicktime
            -tag:v hvc1 \
            # Streaming
            -movflags faststart \
            -q:v $QUALITY \
            -f mp4 \
            $OUT
    end

    function archive_hevc_8bit
        if [ (count $argv) -lt 2 ]
            echo "Usage example: "(status current-function)" 70 ./input.mp4"
            return 1
        end
        set QUALITY $argv[1]
        set IN $argv[2]
        set OUT $argv[2]".8-bit.qv"$QUALITY".mp4"
        ffmpeg \
            -i $IN \
            # fast encoding
            -c:v hevc_videotoolbox \
            # 10-bit
            -profile:v main \
            # Needed to play in Quicktime
            -tag:v hvc1 \
            # Streaming
            -movflags faststart \
            -q:v $QUALITY \
            -f mp4 \
            $OUT
    end
