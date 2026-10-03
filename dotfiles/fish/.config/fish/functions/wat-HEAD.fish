function wat-HEAD
    set COMMAND cargo run --release -- $argv
    string join -- " " (string escape -- $COMMAND)
    cd $HOME/Code/git/github.com/lgarron/wat/ && command $COMMAND
end

# False positive
# @fish-lsp-disable-next-line 1004
wat-HEAD --completions fish --bin-name wat-HEAD | source >/dev/null
