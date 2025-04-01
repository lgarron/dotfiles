#!/opt/homebrew/bin/fish --no-config

# set PATH_UTF8 (printf %s $argv[1] | iconv -f "UTF-8" -t "ISO-8859-1")
set PATH_BASE64 (printf %s $argv[1] | base64)
/opt/homebrew/bin/fish --interactive --init-command "cd-dir-from-iterm-base64 "(string escape $PATH_BASE64)
