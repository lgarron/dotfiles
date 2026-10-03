function twips-HEAD
    set COMMAND cargo run --release -- $argv
    string join -- " " (string escape -- $COMMAND)
    cd $HOME/Code/git/github.com/cubing/twips/ && command $COMMAND
end

# False positive
# @fish-lsp-disable-next-line 1004
twips-HEAD completions fish --bin-name twips-HEAD | source >/dev/null
