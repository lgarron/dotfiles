#!/usr/bin/env -S fish --no-config

# TODO:
# - Port to JS (or into `repo`)
# - Combine with `bun-roll.fish`

if test (count $argv) = 0
    echo "Usage: bun-roll [npm package name]"
    exit 255
end

if not test -e package.json
    echo "No package.json in the current folder."
    exit 1
end

jj new # Skip if the current change is empty ahd has no revision

set NPM_PACKAGE $argv[1]

cat package.json | jq -e ".dependencies[\"$NPM_PACKAGE\"]" >/dev/null; or cat package.json | jq -e ".devDependencies[\"$NPM_PACKAGE\"]" >/dev/null; or begin
    echo -n "⚠️ Must already have "
    set_color --bold
    echo -n -- "$NPM_PACKAGE"
    set_color normal
    echo " as a dependency in order to roll versions."
    exit 3
end

if cat package.json | jq -e ".devDependencies[\"$NPM_PACKAGE\"]" >/dev/null
    set -- DEV_ARG --development
end

set VERSION (npm show "$NPM_PACKAGE" version)
echo -n "Rolling "
set_color --bold
echo -n -- "$NPM_PACKAGE"
set_color normal
echo -- " to version: v$VERSION"

bun add $DEV_ARG "$NPM_PACKAGE@^v$VERSION"
jj describe --message "`bun add $DEV_ARG $NPM_PACKAGE@^v$VERSION`"
