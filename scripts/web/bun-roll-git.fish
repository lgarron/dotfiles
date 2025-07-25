#!/usr/bin/env -S fish --no-config

if test (count $argv) = 0
    echo "Usage: bun-roll [npm package name]"
    exit 255
end

if not test -e package.json
    echo "No package.json in the current folder."
    exit 1
end

set STATUS (git status --porcelain)
if test -n "$STATUS"
    echo -n "⚠️ "
    set_color --bold
    echo -n "git status"
    set_color normal
    echo " must be clean"
    exit 2
end

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

bun add $DEV_ARG "$NPM_PACKAGE@^$VERSION"
git stage package.json bun.lock || git stage package.json bun.lockb
git commit -m "`bun add $DEV_ARG $NPM_PACKAGE@^$VERSION`"
