#!/opt/homebrew/bin/fish --no-config

set PATH_UTF8 $argv[1]
set PATH_BASE64 (printf %s $PATH_UTF8 | base64)
/opt/homebrew/bin/fish --interactive --init-command "cd-dir-from-iterm-base64 "(string escape $PATH_BASE64)
