#!/opt/homebrew/bin/fish --no-config

/opt/homebrew/bin/fish --interactive --init-command "cd-dir-from-iterm "(string escape $argv[1])
