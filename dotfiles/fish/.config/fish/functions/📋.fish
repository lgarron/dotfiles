function 📋
    set DIR (mktemp -d -t pipe)

    mkfifo $DIR/PIPE $DIR/CLIPBOARD

    cat - | tee $DIR/PIPE $DIR/CLIPBOARD | cat >/dev/null &
    cat $DIR/PIPE &

    # Adapated from: https://jvns.ca/blog/2025/06/24/new-zine--the-secret-rules-of-the-terminal/#i-learned-a-surprising-amount-writing-this-zine
    printf "\033]52;c;%s\007" (cat $DIR/CLIPBOARD | base64 | tr -d '\n') &
    wait

    rm -rf $DIR
end
