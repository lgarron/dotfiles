function mak-HEAD
    set COMMAND cargo run --manifest-path $HOME/Code/git/github.com/lgarron/mak/Cargo.toml --release -- $argv
    string join -- " " (string escape -- $COMMAND)
    command $COMMAND
end

# False positive
# @fish-lsp-disable-next-line 1004
mak-HEAD --completions fish --bin-name mak-HEAD | source >/dev/null
