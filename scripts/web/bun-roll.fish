#!/usr/bin/env -S fish --no-config

if string match --quiet --entire -- (repo vcs kind) jj
    bun-roll-jj $argv
else if string match --quiet --entire -- (repo vcs kind) git
    bun-roll-git $argv
else
    echo "Could not determine VCS."
    exit 1
end
