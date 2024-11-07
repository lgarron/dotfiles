#!/usr/bin/env -S fish --no-config

if contains -- "--completions" $argv
  # This does *not* check the argument order, but that's good enough to avoid Homebrew install failures.
  if contains -- "fish" $argv
    # From https://codybonney.com/getting-a-list-of-local-git-branches-without-using-git-branch/
    echo "complete -c rmtag -a \"(git tag --list)\""
  end
  exit 0
end

if [ (count $argv) -eq 0 ]
  echo "Usage: rmtag <tag-name> [more branch names]"
  echo ""
  echo "Remove `git` tags locally and remotely."
end

for TAG in $argv
  git tag -d $TAG; or echo "Did not need to remove tag locally"
  echo "--------"
  git push origin :$TAG; or echo "Did not need to remove tag from origin"
  echo "--------"
  gh release delete $TAG; or echo "Did not need to remove release from origin"
end
