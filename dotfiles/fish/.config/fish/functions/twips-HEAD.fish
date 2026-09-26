function twips-HEAD
    set COMMAND cargo run --release -- $argv
    string join -- " " (string escape -- $COMMAND)
    cd $HOME/Code/git/github.com/cubing/twips/ && command $COMMAND
end
