#!/usr/bin/env -S fish --no-config

set PATH_UTF8 (printf %s $argv[1] | iconv -f "UTF-8" -t "ISO-8859-1")

if not test -d $PATH_UTF8
    set PATH_UTF8 (dirname $PATH_UTF8)
end

open -a "Visual Studio Code" $PATH_UTF8

return 1 # To avoid showing results in Quicksilver
