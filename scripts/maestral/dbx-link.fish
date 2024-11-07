#!/usr/bin/env -S fish --no-config

set REALPATH (realpath $argv[1])
if string match "$HOME/Dropbox (Maestral)/*" $REALPATH > /dev/null

    function print_path
        set_color --bold blue
        echo -- $argv[1]
        set_color normal
        echo -- $argv[1] | pbcopy
    end

    echo "[Absolute path]"
    print_path "$REALPATH"
    set DROPBOX_PATH (string replace "$HOME/Dropbox (Maestral)/" "" $REALPATH)
    echo "[Dropbox relative path]"
    print_path "$DROPBOX_PATH"
    echo ""

    function print_copy_path
        echo "[Copying to clipboard]"
        print_path $argv[1]
        echo -- $argv[1] | pbcopy
    end

    function create_copy
        set COPY_PATH (maestral sharelink create $DROPBOX_PATH); or return 1
        echo "🆕 Created new URL"
        print_copy_path "$COPY_PATH"
    end

    function list_copy
        set COPY_PATH (maestral sharelink list $DROPBOX_PATH | head -n1)
        echo "♻️ Used existing URL"
        print_copy_path "$COPY_PATH"
    end

    # Note: We need to try to create the link first, in case the only existing links are for parent folders.
    # If (and only if) this errors due to an existing link, that means there is an existing link for the path itself, and so we can copy that.
    create_copy ; or list_copy
else
    echo "Not in the Maestral Dropbox folder: $REALPATH"
end
