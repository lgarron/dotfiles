function mak-HEAD
    set COMMAND cargo run --manifest-path $HOME/Code/git/github.com/lgarron/mak/Cargo.toml -- $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end
