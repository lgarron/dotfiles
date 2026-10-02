function folderify-HEAD
    set COMMAND cargo run --manifest-path $HOME/Code/git/github.com/lgarron/folderify/Cargo.toml --release -- $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end

# False positive
# @fish-lsp-disable-next-line 1004
folderify-HEAD --completions fish --bin-name folderify-HEAD | source >/dev/null
