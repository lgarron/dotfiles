## `dev`

## `make

    abbr -a --position command m "make"

    # Allow the first (and usually the only) target to be combined with the initial `m`:
    # Additional targets can be expanded using the argument abbreviations below.
    abbr -a mb "make build"
    abbr -a mc "make clean"
    abbr -a md "make dev"
    abbr -a mdp "make deploy"
    abbr -a mp "make publish"
    abbr -a mt "make test"
    abbr -a mta "make test-all"
    abbr -a ml "make lint"
    abbr -a mf "make format"
    abbr -a mcd "# Try: m c d"
    abbr -a mcb "# Try: m c b"

    function _abbr_make_build_fn; _abbr_define_anyarg build make; end; abbr -a _abbr_make_build --regex b --position anywhere --function _abbr_make_build_fn
    function _abbr_make_dev_fn; _abbr_define_anyarg dev make; end; abbr -a _abbr_make_dev --regex d --position anywhere --function _abbr_make_dev_fn
    function _abbr_make_clean_fn; _abbr_define_anyarg clean make; end; abbr -a _abbr_make_clean --regex c --position anywhere --function _abbr_make_clean_fn
    function _abbr_make_deploy_fn; _abbr_define_anyarg deploy make; end; abbr -a _abbr_make_deploy --regex dp --position anywhere --function _abbr_make_deploy_fn
    function _abbr_make_publish_fn; _abbr_define_anyarg publish make; end; abbr -a _abbr_make_publish --regex p --position anywhere --function _abbr_make_publish_fn
    function _abbr_make_test_fn; _abbr_define_anyarg test make; end; abbr -a _abbr_make_test --regex t --position anywhere --function _abbr_make_test_fn
    function _abbr_make_test_all_fn; _abbr_define_anyarg test-all make; end; abbr -a _abbr_make_test_all --regex ta --position anywhere --function _abbr_make_test_all_fn
    function _abbr_make_lint_fn; _abbr_define_anyarg lint make; end; abbr -a _abbr_make_lint --regex l --position anywhere --function _abbr_make_lint_fn
    function _abbr_make_format_fn; _abbr_define_anyarg format make; end; abbr -a _abbr_make_format --regex f --position anywhere --function _abbr_make_format_fn

## `node`

    abbr -a n "npm"

    abbr -a niy "npm init -y ; and jq --indent 2 '.type=\"module\" | del(.main)' package.json > /tmp/package.json ; and cat /tmp/package.json > package.json"
    abbr -a ni "npm install;"
    abbr -a nis "npm install --save"
    abbr -a nid "npm install --save-dev"
    abbr -a nr "npm run"
    abbr -a nl "npm link"

    function _abbr_npm_install_fn; _abbr_define_subcommand install npm i; end; abbr -a _abbr_npm_install --regex i --position anywhere --function _abbr_npm_install_fn
    function _abbr_npm_uninstall_fn; _abbr_define_subcommand uninstall npm u; end; abbr -a _abbr_npm_uninstall --regex u --position anywhere --function _abbr_npm_uninstall_fn
    function _abbr_npm_run_fn; _abbr_define_subcommand run npm i; end; abbr -a _abbr_npm_run --regex r --position anywhere --function _abbr_npm_run_fn
    function _abbr_npm_link_fn; _abbr_define_subcommand link npm l; end; abbr -a _abbr_npm_link --regex l --position anywhere --function _abbr_npm_link_fn

    # npm install s⎵ → npm install --save
    function _abbr_npm_install_save_fn; _abbr_define_subcommand_arg --save npm install; end; abbr -a _abbr_npm_install_save --regex s --position anywhere --function _abbr_npm_install_save_fn

    # npm install d⎵ → npm install --save-dev
    function _abbr_npm_install_save_dev_fn; _abbr_define_subcommand_arg --save-dev npm install; end; abbr -a _abbr_npm_install_save_dev --regex d --position anywhere --function _abbr_npm_install_save_dev_fn

    # npm run d⎵ → npm run dev
    function _abbr_npm_run_d_fn; _abbr_define_subcommand_arg dev npm run; end; abbr -a _abbr_npm_run_d --regex d --position anywhere --function _abbr_npm_run_d_fn
    # npm run b⎵ → npm run build
    function _abbr_npm_run_b_fn; _abbr_define_subcommand_arg build npm run; end; abbr -a _abbr_npm_run_b --regex b --position anywhere --function _abbr_npm_run_b_fn

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

# Cargo

    abbr -a co "cargo"

    abbr -a ca "cargo add"
    abbr -a cb "cargo build"
    abbr -a cf "cargo fmt"
    abbr -a ct "cargo test"
    abbr -a cr "cargo run --"
    abbr -a crh "cargo run -- --help"

    function _abbr_cargo_add_fn; _abbr_define_anyarg add cargo; end; abbr -a _abbr_cargo_add --regex a --position anywhere --function _abbr_cargo_add_fn
    function _abbr_cargo_build_fn; _abbr_define_anyarg build cargo; end; abbr -a _abbr_cargo_build --regex b --position anywhere --function _abbr_cargo_build_fn
    function _abbr_cargo_fmt_fn; _abbr_define_anyarg fmt cargo; end; abbr -a _abbr_cargo_fmt --regex f --position anywhere --function _abbr_cargo_fmt_fn
    function _abbr_cargo_test_fn; _abbr_define_anyarg test cargo; end; abbr -a _abbr_cargo_test --regex t --position anywhere --function _abbr_cargo_test_fn
    function _abbr_cargo_run_fn; _abbr_define_anyarg "run --" cargo; end; abbr -a _abbr_cargo_run --regex r --position anywhere --function _abbr_cargo_run_fn

    # cargo run h⎵ → cargo run --help
    function _abbr_cargo_run_help_fn; _abbr_define_subcommand_arg "--help" cargo run; end; abbr -a _abbr_cargo_run_help --regex h --position anywhere --function _abbr_cargo_run_help_fn

## Web

    # *h*ttps *h*eaders
    abbr -a "hh" "https -ph"

## Misc

    abbr -a "cx" "chmod +x"
    abbr -a "p3" "python3"
    abbr -a "dig" "xdig"
    abbr -a "pod" "gp"
