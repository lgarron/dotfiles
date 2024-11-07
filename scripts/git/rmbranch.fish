#!/usr/bin/env -S fish --no-config

if contains -- "--completions" $argv
  # This does *not* check the argument order, but that's good enough to avoid Homebrew install failures.
  if contains -- "fish" $argv
    # From https://codybonney.com/getting-a-list-of-local-git-branches-without-using-git-branch/
    echo "complete -c rmbranch -f
complete -c rmbranch -a \"(git for-each-ref --format '%(refname:short)' refs/heads/)\"

function abbr_rmbranch_lastbranch_fn
    _abbr_expand_anyarg rmbranch b- (git rev-parse --abbrev-ref @{-1})
end
abbr -a abbr_rmbranch_lastbranch --regex b- --position anywhere --function abbr_rmbranch_lastbranch_fn"
  end
  exit 0
end

if [ (count $argv) -eq 0 ]
  echo "Usage: rmbranch <branch-name> [more branch names]"
  echo ""
  echo "Print `fish` completions using: `rmbranch --completions`"
  echo ""
  echo "Remove `git` branches locally and remotely."
end

for BRANCH in $argv
  echo "Branch `$BRANCH` was at: "(git rev-parse $BRANCH)
  git push origin :$BRANCH
  git branch -D $BRANCH
end
