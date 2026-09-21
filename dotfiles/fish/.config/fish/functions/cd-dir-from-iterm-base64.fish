function cd-dir-from-iterm-base64
    cd-dir-from-iterm (printf %s $argv[1] | base64 --decode)
end
