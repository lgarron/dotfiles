#!/usr/bin/env -S fish --no-config

if [ (count $argv) -eq 0 ]
set BASE_NAME status --current-filename
echo "Usage: $BASE_NAME [base branch] branch

Example:

    > git distance origin/main local-feature-branch
    2 commits on origin/main
    3 commits on local-feature-branch

If the base branch is not specified, the current branch is used.
"
exit 1
end

if [ (count $argv) -lt 2 ]
    set CURRENT (git rev-parse --abbrev-ref HEAD)
    set OTHER $argv[1]
else
    set CURRENT $argv[1]
    set OTHER $argv[2]
end

git rev-list --left-only --count $CURRENT...$OTHER | tr -d '\n'
echo -n " commit(s) on "
set_color -o
echo "$CURRENT"
set_color normal

git rev-list --right-only --count $CURRENT...$OTHER | tr -d '\n'
echo -n " commit(s) on "
set_color -o
echo "$OTHER"
set_color normal
