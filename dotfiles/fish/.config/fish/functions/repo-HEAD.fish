function repo-HEAD
    set COMMAND cargo run --manifest-path $HOME/Code/git/github.com/lgarron/repo/Cargo.toml -- $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end
